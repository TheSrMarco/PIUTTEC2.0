from django.core.management.base import BaseCommand
from recursos.models import Recurso


class Command(BaseCommand):
    help = 'Crea cuatro recursos FICTICIOS de práctica. No representa inventario oficial.'

    def handle(self, *args, **options):
        records = [
            ('laboratorio', 'Laboratorio de Software (demo)', 'Edificio de práctica', 30),
            ('laboratorio', 'Laboratorio de Redes (demo)', 'Edificio de práctica', 25),
            ('equipo', 'Laptop de préstamo (demo)', 'Almacén de práctica', 1),
            ('equipo', 'Proyector multimedia (demo)', 'Almacén de práctica', 1),
        ]
        count = 0
        for tipo, nombre, ubicacion, capacidad in records:
            _, created = Recurso.objects.get_or_create(tipo=tipo, nombre=nombre,
                defaults={'ubicacion': ubicacion, 'capacidad': capacidad, 'activo': True})
            count += int(created)
        self.stdout.write(self.style.SUCCESS(f'Agregados: {count} recursos ficticios (demo).'))
