"""Validación de registro y perfiles. Nunca se exponen hashes ni privilegios de escritura pública."""
from django.contrib.auth import get_user_model, password_validation
from django.contrib.auth.validators import UnicodeUsernameValidator
from rest_framework import serializers

User = get_user_model()


def unique_identity(attrs, instance=None):
    queryset = User.objects.all()
    if instance is not None:
        queryset = queryset.exclude(pk=instance.pk)
    if 'username' in attrs and queryset.filter(username__iexact=attrs['username'].strip()).exists():
        raise serializers.ValidationError({'username': 'Este usuario ya está registrado.'})
    if 'email' in attrs and queryset.filter(email__iexact=attrs['email'].strip()).exists():
        raise serializers.ValidationError({'email': 'Este correo ya está registrado.'})
    return attrs


class UserPublicSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'first_name', 'last_name', 'email', 'role', 'date_joined', 'is_staff')
        read_only_fields = ('id', 'role', 'date_joined', 'is_staff')
        extra_kwargs = {'email': {'required': True, 'allow_blank': False}}

    def validate(self, attrs):
        return unique_identity(attrs, self.instance)


class UserRegisterSerializer(serializers.ModelSerializer):
    username = serializers.CharField(max_length=150, validators=[UnicodeUsernameValidator()])
    email = serializers.EmailField(required=True, allow_blank=False)
    password = serializers.CharField(write_only=True, trim_whitespace=False, style={'input_type': 'password'})
    password_confirm = serializers.CharField(write_only=True, trim_whitespace=False, style={'input_type': 'password'})
    accepted_privacy = serializers.BooleanField(write_only=True)

    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name', 'password', 'password_confirm', 'accepted_privacy')
        read_only_fields = ('id',)

    def validate(self, attrs):
        unique_identity(attrs)
        if not attrs.get('accepted_privacy'):
            raise serializers.ValidationError({'accepted_privacy': 'Debes confirmar la lectura de la información de privacidad del prototipo.'})
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({'password_confirm': 'Las contraseñas no coinciden.'})
        candidate = User(username=attrs['username'].strip(), email=attrs['email'].strip(),
                         first_name=attrs.get('first_name', ''), last_name=attrs.get('last_name', ''))
        try:
            password_validation.validate_password(attrs['password'], user=candidate)
        except Exception as exc:
            from django.core.exceptions import ValidationError
            if isinstance(exc, ValidationError):
                raise serializers.ValidationError({'password': exc.messages}) from exc
            raise
        return attrs

    def create(self, validated_data):
        validated_data.pop('password_confirm', None)
        validated_data.pop('accepted_privacy', None)
        password = validated_data.pop('password')
        # Los privilegios NUNCA se aceptan del cliente en el registro público.
        validated_data['role'] = User.Role.STUDENT
        return User.objects.create_user(password=password, **validated_data)


class ChangePasswordSerializer(serializers.Serializer):
    current_password = serializers.CharField(write_only=True, trim_whitespace=False)
    new_password = serializers.CharField(write_only=True, trim_whitespace=False)
    new_password_confirm = serializers.CharField(write_only=True, trim_whitespace=False)

    def validate(self, attrs):
        user = self.context['request'].user
        if not user.check_password(attrs['current_password']):
            raise serializers.ValidationError({'current_password': 'La contraseña actual no es correcta.'})
        if attrs['new_password'] != attrs['new_password_confirm']:
            raise serializers.ValidationError({'new_password_confirm': 'Las nuevas contraseñas no coinciden.'})
        try:
            password_validation.validate_password(attrs['new_password'], user=user)
        except Exception as exc:
            from django.core.exceptions import ValidationError
            if isinstance(exc, ValidationError):
                raise serializers.ValidationError({'new_password': exc.messages}) from exc
            raise
        return attrs


class AdminUserSerializer(UserPublicSerializer):
    class Meta(UserPublicSerializer.Meta):
        fields = UserPublicSerializer.Meta.fields + ('is_active',)
        read_only_fields = ('id', 'date_joined', 'is_staff')
