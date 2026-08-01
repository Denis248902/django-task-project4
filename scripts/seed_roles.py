from django.contrib.auth.models import Group, User
from django.db import transaction


@transaction.atomic
def run():
    editors, _ = Group.objects.get_or_create(name="editors")
    admins, _ = Group.objects.get_or_create(name="admins")
    viewers, _ = Group.objects.get_or_create(name="viewers")

    users = {}
    for username, password in [
        ("admin_user", "admin123"),
        ("editor_user", "editor123"),
        ("viewer_user", "viewer123"),
    ]:
        user, created = User.objects.get_or_create(username=username)
        if created:
            user.set_password(password)
            user.is_staff = True
            user.save()
        users[username] = user

    users["admin_user"].groups.set([admins])
    users["editor_user"].groups.set([editors])
    users["viewer_user"].groups.set([viewers])

    print("✅ Роли назначены.")


if __name__ == "__main__":
    run()
