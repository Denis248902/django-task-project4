from django.db import models
from django.contrib.auth.models import User
from decimal import Decimal

REASON_CHOICES = [
    ('birthday', 'День рождения'),
    ('wedding', 'Свадьба'),
    ('moving', 'Переезд'),
    ('gift', 'Подарок'),
    ('other', 'Другое'),
]

class Collect(models.Model):
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='collects')
    title = models.CharField(max_length=200)
    reason = models.CharField(max_length=50, choices=REASON_CHOICES, default='other')
    description = models.TextField(blank=True)
    target_amount = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)  # можно None = «бесконечный»
    current_amount = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal('0.00'))
    cover_image = models.ImageField(upload_to='collects/', blank=True, null=True)
    deadline = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} ({self.reason})"


class Payment(models.Model):
    collect = models.ForeignKey(Collect, on_delete=models.CASCADE, related_name='payments')
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    paid_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} — {self.amount} в {self.collect.title}"
