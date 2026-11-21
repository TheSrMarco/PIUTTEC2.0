from django.db import OperationalError, connection, transaction
from django.shortcuts import get_object_or_404
from rest_framework.decorators import api_view
from rest_framework.exceptions import APIException, PermissionDenied, ValidationError
from rest_framework.response import Response

from .models import Attendance, Course
from .serializers import AttendanceBatchSerializer, DayQuerySerializer


def is_administrator(user):
    return user.is_superuser or user.role == "administrator"


def can_edit(user, course):
    return is_administrator(user) or (
        user.role == "teacher" and course.teacher_id == user.pk
    )


def available_courses(user):
    courses = Course.objects.all()
    if is_administrator(user):
        return courses
    if user.role == "teacher":
        return courses.filter(teacher=user)
    return courses.filter(enrollments__student=user)


@api_view(["GET"])
def course_list(request):
    return Response({"courses": [{
        "id": course.pk,
        "name": course.name,
        "code": course.code,
        "group": course.group,
        "period": course.period,
        "can_edit": can_edit(request.user, course),
    } for course in available_courses(request.user)]})


def day_response(user, course, date):
    enrollments = course.enrollments.select_related("student")
    editable = can_edit(user, course)
    if not editable:
        enrollments = enrollments.filter(student=user)
    records = {
        row.enrollment_id: row
        for row in Attendance.objects.filter(enrollment__course=course, date=date)
    }
    students = []
    for enrollment in enrollments:
        record = records.get(enrollment.pk)
        students.append({
            "enrollment_id": enrollment.pk,
            "name": enrollment.student.get_full_name() or enrollment.student.username,
            "student_code": enrollment.student.username,
            "status": record.status if record else None,
            "note": record.note if record else "",
            "time_in": record.time_in.strftime("%H:%M") if record and record.time_in else None,
            "version": record.version if record else 0,
        })
    return {
        "course_id": course.pk,
        "date": date.isoformat(),
        "can_edit": editable,
        "students": students,
    }


class AttendanceConflict(APIException):
    status_code = 409
    default_detail = "La lista cambió. Recargue los registros antes de guardar."
    default_code = "attendance_conflict"


@api_view(["GET", "POST"])
def attendance_day(request, course_id):
    course = get_object_or_404(available_courses(request.user), pk=course_id)
    if request.method == "GET":
        query = DayQuerySerializer(data=request.query_params)
        query.is_valid(raise_exception=True)
        return Response(day_response(request.user, course, query.validated_data["date"]))

    if not can_edit(request.user, course):
        raise PermissionDenied("Su cuenta permite consultar su asistencia.")
    payload = AttendanceBatchSerializer(data=request.data)
    payload.is_valid(raise_exception=True)
    date = payload.validated_data["date"]
    requested = payload.validated_data["records"]
    try:
        with transaction.atomic():
            # Serializa los cambios de la misma materia en PostgreSQL.
            course = Course.objects.select_for_update().get(pk=course.pk)
            if not can_edit(request.user, course):
                raise PermissionDenied("La asignación de la materia cambió.")
            enrollment_ids = set(course.enrollments.values_list("pk", flat=True))
            if any(row["enrollment_id"] not in enrollment_ids for row in requested):
                raise ValidationError("La lista contiene estudiantes de otra materia.")
            stored = {
                row.enrollment_id: row
                for row in Attendance.objects.filter(enrollment__course=course, date=date)
            }
            for row in requested:
                current = stored.get(row["enrollment_id"])
                status = row["status"]
                same = (
                    current is None and status is None
                ) or (
                    current is not None
                    and current.status == status
                    and current.note == row["note"]
                    and current.time_in == row["time_in"]
                )
                if same:
                    continue
                if row["version"] != (current.version if current else 0):
                    raise AttendanceConflict()
                Attendance.objects.update_or_create(
                    enrollment_id=row["enrollment_id"], date=date,
                    defaults={
                        "status": status, "note": row["note"], "time_in": row["time_in"],
                        "recorded_by": request.user,
                        "version": current.version + 1 if current else 1,
                    },
                )
            result = day_response(request.user, course, date)
    except OperationalError as error:
        if connection.vendor == "sqlite" and "locked" in str(error).lower():
            raise AttendanceConflict() from error
        raise
    return Response(result)
