from decimal import Decimal

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand
from django.db.models import Sum
from django.utils import timezone

from collects.models import Collect, Payment  # <-- берём модели отсюда


class Command(BaseCommand):
    help = "Создаёт тестовые сборы и платежи для проверки API"

    def handle(self, *args, **options):
        self.stdout.write("🚀 Запуск seed_collects...")

        try:
            editor_user = User.objects.get(username="editor_user")
            viewer_user = User.objects.get(username="viewer_user")
        except User.DoesNotExist as e:
            self.stderr.write(
                f"❌ Ошибка: пользователь не найден. Сначала создай пользователей. Детали: {e}"
            )
            return

        self.stdout.write("✅ Пользователи найдены.")

        deadline = timezone.now().replace(
            year=2026,
            month=12,
            day=31,
            hour=23,
            minute=59,
            second=59,
        )

        collect = Collect.objects.create(
            author=editor_user,
            title="День рождения команды",
            reason="birthday",
            description="Собираем на торт и подарки",
            target_amount=Decimal("10000.00"),
            deadline=deadline,
        )
        self.stdout.write(f"✅ Сбор создан, ID: {collect.id}")

        Payment.objects.create(
            collect=collect,
            user=viewer_user,
            amount=Decimal("2000"),
        )
        self.stdout.write("💸 Платёж 1 (2000) от viewer_user создан.")

        Payment.objects.create(
            collect=collect,
            user=editor_user,
            amount=Decimal("1500"),
        )
        self.stdout.write("💸 Платёж 2 (1500) от editor_user создан.")

        total = collect.payments.aggregate(total=Sum("amount"))["total"] or 0
        collect.current_amount = total
        collect.save(update_fields=["current_amount"])

        self.stdout.write(f"💰 current_amount = {total} (ожидается 3500)")
        self.stdout.write("🎉 seed_collects успешно завершён!")
