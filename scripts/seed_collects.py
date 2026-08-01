from django.contrib.auth.models import User
from collects.models import Collect, Payment
from django.utils import timezone
from datetime import timedelta

def run():
    # Берём любого пользователя как автора (лучше не viewer, а staff)
    author = User.objects.filter(is_staff=True).first()
    if not author:
        print("❌ Нет пользователей с is_staff=True. Сначала запустите seed_roles.")
        return

    collects = []
    for i in range(3):
        collect = Collect.objects.create(
            author=author,
            title=f"Сбор #{i+1}: Подарок на ДР",
            reason="birthday",
            description=f"Собираем на подарок для именинника #{i+1}",
            target_amount=10000.00,
            deadline=timezone.now() + timedelta(days=7 + i),
        )
        collects.append(collect)

        # Добавляем 2 платежа к каждому сбору
        for j in range(2):
            payer = User.objects.exclude(username=author.username).first() or author
            Payment.objects.create(
                collect=collect,
                user=payer,
                amount=1500.00 + j * 500,
            )

    print(f"✅ Создано {len(collects)} сборов и {2 * len(collects)} платежей.")

if __name__ == '__main__':
    run()
