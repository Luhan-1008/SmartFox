from rest_framework import permissions

# permissions.py
class IsTeacherOrReadOnly(permissions.BasePermission):
    message = '只有教师账号可以发布或修改学习资料'

    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        user = getattr(request, 'user', None)
        role = getattr(user, 'role', '')
        return bool(getattr(user, 'is_authenticated', False) and str(role).strip().lower() == 'teacher')
