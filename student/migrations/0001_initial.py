# Generated by Django 5.0.4 on 2024-04-17 23:43

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name="Student",
            fields=[
                ("create_at", models.DateTimeField(auto_now_add=True)),
                ("update_at", models.DateTimeField(auto_now=True)),
                ("id", models.BigAutoField(primary_key=True, serialize=False)),
                ("name", models.CharField(max_length=255)),
                ("age", models.IntegerField()),
                ("email", models.EmailField(max_length=254)),
                ("telephone", models.CharField(max_length=20)),
            ],
            options={
                "abstract": False,
            },
        ),
    ]
