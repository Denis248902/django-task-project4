from django.contrib.auth import get_user_model
from django.core.validators import MinValueValidator
from django.db import models
from django.utils import timezone

User = get_user_model()

REASON_CHOICES = [
    ("birthday", "День рождения"),
    ("wedding", "Свадьба"),
    ("moving", "Переезд"),
    ("gift", "Подарок"),
    ("other", "Другое"),
]


class Collect(models.Model):
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name="collects")
    title = models.CharField(max_length=200)
    reason = models.CharField(max_length=50, choices=REASON_CHOICES)
    description = models.TextField(blank=True)
    target_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(0)],
        null=True,
        blank=True,
    )
    current_amount = models.DecimalField(
        max_digits=12, decimal_places=2, default=0, editable=False
    )
    cover_image = models.ImageField(upload_to="collects/", blank=True, null=True)
    deadline = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} ({self.author})"

    class Meta:
        ordering = ["-created_at"]


class Payment(models.Model):
    collect = models.ForeignKey(
        Collect, on_delete=models.CASCADE, related_name="payments"
    )
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="payments")
    amount = models.DecimalField(
        max_digits=12, decimal_places=2, validators=[MinValueValidator(0.01)]
    )
    paid_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Payment {self.amount} for {self.collect.title}"

    class Meta:
        ordering = ["-paid_at"]
