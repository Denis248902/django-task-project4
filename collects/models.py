from django.conf import settings
from django.db import models
from django.utils import timezone


class Collect(models.Model):
    REASON_CHOICES = [
        ('birthday', 'День рождения'),
        ('wedding', 'Свадьба'),
        ('anniversary', 'Юбилей'),
        ('charity', 'Благотворительность'),
        ('other', 'Другое'),
    ]

    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='collects',
    )
    title = models.CharField(max_length=200)
    reason = models.CharField(max_length=50, choices=REASON_CHOICES)
    description = models.TextField(blank=True)
    target_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
    )  # None = «бесконечный» сбор
    current_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0,
    )
    cover_image = models.ImageField(upload_to='collects/', blank=True, null=True)
    deadline = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} ({self.author.username})"


class Payment(models.Model):
    collect = models.ForeignKey(Collect, on_delete=models.CASCADE, related_name='payments')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    paid_at = models.DateTimeField(default=timezone.now)

    class Meta:
        ordering = ['-paid_at']

    def __str__(self):
        return f"{self.user.username} — {self.amount} для {self.collect.title}"
