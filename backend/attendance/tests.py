from datetime import timedelta

from django.contrib.auth import get_user_model
from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient

from .models import Attendance, Course, Enrollment


class AttendanceApiTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        User = get_user_model()
        cls.teacher = User.objects.create_user(username="teacher", password="Test-only-984!", role="teacher")
        cls.other_teacher = User.objects.create_user(username="other", role="teacher")
        cls.student = User.objects.create_user(username="student", role="student")
        cls.other_student = User.objects.create_user(username="student2", role="student")
        cls.course = Course.objects.create(code="A", name="Redes", group="A", period="2026-3", teacher=cls.teacher)
        cls.other_course = Course.objects.create(code="B", name="Programación", group="B", period="2026-3", teacher=cls.other_teacher)
        cls.enrollment = Enrollment.objects.create(course=cls.course, student=cls.student)
        cls.peer = Enrollment.objects.create(course=cls.course, student=cls.other_student)
        cls.foreign_enrollment = Enrollment.objects.create(course=cls.other_course, student=cls.student)
        cls.date = timezone.localdate().isoformat()
        cls.url = f"/api/courses/{cls.course.pk}/attendance/"

    def setUp(self):
        self.client = APIClient()
        self.client.force_authenticate(self.teacher)

    def row(self, enrollment, status, version=0, note=""):
        return {
            "enrollment_id": enrollment.pk, "status": status,
            "version": version, "note": note, "time_in": None,
        }

    def save(self, records, date=None, url=None):
        return self.client.post(url or self.url, {
            "date": date or self.date, "records": records,
        }, format="json")

    def test_login_profile_and_refresh_through_real_jwt(self):
        client = APIClient()
        self.assertEqual(client.get("/api/auth/me/").status_code, 401)
        self.assertEqual(client.get("/api/courses/").status_code, 401)
        invalid = client.post("/api/auth/login/", {"username": "teacher", "password": "incorrect"}, format="json")
        self.assertEqual(invalid.status_code, 401)
        login = client.post("/api/auth/login/", {"username": "teacher", "password": "Test-only-984!"}, format="json")
        self.assertEqual(login.status_code, 200)
        client.credentials(HTTP_AUTHORIZATION=f"Bearer {login.data['access']}")
        profile = client.get("/api/auth/me/")
        self.assertEqual(profile.data["id"], self.teacher.pk)
        self.assertEqual(profile.data["role"], "teacher")
        refresh = client.post("/api/auth/refresh/", {"refresh": login.data["refresh"]}, format="json")
        self.assertEqual(refresh.status_code, 200)
        self.assertIn("access", refresh.data)

    def test_teacher_saves_and_retries_without_duplicate_records(self):
        payload = [self.row(self.enrollment, "present", note="Participó")]
        first = self.save(payload)
        self.assertEqual(first.status_code, 200)
        self.assertEqual(self.save(payload).status_code, 200)
        record = Attendance.objects.get()
        self.assertEqual(record.version, 1)
        self.assertEqual(record.note, "Participó")
        self.assertEqual(record.recorded_by, self.teacher)
        loaded = self.client.get(self.url, {"date": self.date})
        self.assertEqual(loaded.status_code, 200)
        self.assertEqual(loaded.data["students"][0]["version"], 1)

    def test_student_only_sees_own_records_and_cannot_save(self):
        self.save([self.row(self.enrollment, "present"), self.row(self.peer, "absent")])
        self.client.force_authenticate(self.student)
        loaded = self.client.get(self.url, {"date": self.date})
        self.assertEqual(loaded.status_code, 200)
        self.assertFalse(loaded.data["can_edit"])
        self.assertEqual([row["enrollment_id"] for row in loaded.data["students"]], [self.enrollment.pk])
        self.assertEqual(self.save([self.row(self.enrollment, "absent", 1)]).status_code, 403)
        record = Attendance.objects.get(enrollment=self.enrollment)
        self.assertEqual(record.status, "present")

    def test_teacher_cannot_access_other_teacher_course(self):
        url = f"/api/courses/{self.other_course.pk}/attendance/"
        self.assertEqual(self.client.get(url, {"date": self.date}).status_code, 404)
        self.assertEqual(self.save([self.row(self.foreign_enrollment, "present")], url=url).status_code, 404)
        courses = self.client.get("/api/courses/")
        self.assertEqual([course["id"] for course in courses.data["courses"]], [self.course.pk])

    def test_outside_student_invalid_status_and_future_date_rejected(self):
        outsider = self.save([self.row(self.enrollment, "present"), self.row(self.foreign_enrollment, "absent")])
        self.assertEqual(outsider.status_code, 400)
        self.assertFalse(Attendance.objects.exists())
        self.assertEqual(self.save([self.row(self.enrollment, "invalid")]).status_code, 400)
        future = (timezone.localdate() + timedelta(days=1)).isoformat()
        self.assertEqual(self.save([self.row(self.enrollment, "present")], date=future).status_code, 400)
        self.assertEqual(self.client.get(self.url, {"date": "not-a-date"}).status_code, 400)
        self.assertEqual(self.save([self.row(self.enrollment, "present")] * 2).status_code, 400)
        self.assertEqual(self.save([self.row(self.enrollment, "present", note="a" * 256)]).status_code, 400)

    def test_conflict_rolls_back_entire_batch(self):
        self.save([self.row(self.enrollment, "present"), self.row(self.peer, "present")])
        changed = self.save([
            self.row(self.enrollment, "absent", version=1),
            self.row(self.peer, "late", version=0),
        ])
        self.assertEqual(changed.status_code, 409)
        self.assertEqual(
            list(Attendance.objects.order_by("enrollment_id").values_list("status", "version")),
            [("present", 1), ("present", 1)],
        )

    def test_clearing_and_reregistering_retains_conflict_version(self):
        self.save([self.row(self.enrollment, "present")])
        self.assertEqual(self.save([self.row(self.enrollment, None, 1)]).status_code, 200)
        self.assertEqual(self.save([self.row(self.enrollment, "late", 2)]).status_code, 200)
        stale = self.save([self.row(self.enrollment, "absent", 1)])
        self.assertEqual(stale.status_code, 409)
        record = Attendance.objects.get()
        self.assertEqual((record.status, record.version), ("late", 3))

    def test_attendance_is_independent_per_course_and_date(self):
        self.save([self.row(self.enrollment, "present")])
        yesterday = (timezone.localdate() - timedelta(days=1)).isoformat()
        self.save([self.row(self.enrollment, "absent")], date=yesterday)
        self.client.force_authenticate(self.other_teacher)
        other_url = f"/api/courses/{self.other_course.pk}/attendance/"
        self.save([self.row(self.foreign_enrollment, "late")], url=other_url)
        self.assertEqual(Attendance.objects.count(), 3)
