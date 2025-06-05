import requests
import pymysql

# Połączenie z bazą danych MySQL
connection = pymysql.connect(
    host="localhost",
    user="root",
    password="1234",
    database="animal_hotel",
    charset="utf8mb4",
    cursorclass=pymysql.cursors.DictCursor,
)

# Url API i token
url = "http://127.0.0.1:8000"
headers = {
    "Authorization": "JWT eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzQ5NDAxNDQ5LCJpYXQiOjE3NDY4MDk0NDksImp0aSI6ImI1MGZjOTZlNzk4YjRkYWFiOGQzOTBkOGI1ODQ3NWUxIiwidXNlcl9pZCI6MX0.UZ5bJ3AnLThRmwRUQGnT-shE7yT-N7Ev0Lf01VAPLNo"
}

# Tabele i ich kolumny
tables = {
    "owners": ["id", "first_name", "last_name", "email", "phone_number"],
    "animals": [
        "id",
        "name",
        "sex",
        "species",
        "age",
        "energy_level",
        "is_friendly",
        "notes",
        "owner_id",
    ],
    "services": ["id", "name", "description"],
    "enclosures": ["id", "symbol", "species"],
    "reservations": [
        "id",
        "status",
        "start_date",
        "end_date",
        "notes",
        "enclosure_id",
        "owner_id",
        "animal_id",
    ],
}

# Dla każdej tabeli
for key, value in tables.items():
    value_str = ", ".join(value)
    print(key, value)

    # Wysłanie zapytania GET
    response = requests.get(f"{url}/{key}", headers=headers)

    if response.status_code == 200:
        data = response.json()
    else:
        print(f"Błąd pobierania danych: {response.status_code}")

    # Zapisanie danych do bazy
    try:
        with connection.cursor() as cursor:
            for item in data["results"]:
                values = ()
                placement = ""

                for i in range(len(value)):
                    values += (item[value[i]],)

                    if i == len(value) - 1:
                        placement += "%s"
                    else:
                        placement += "%s, "

                update_fields = ", ".join(
                    [f"{col} = VALUES({col})" for col in value if col != "id"]
                )

                sql = f"""
                INSERT INTO {key} ({value_str})
                VALUES ({placement})
                ON DUPLICATE KEY UPDATE {update_fields};
                """

                cursor.execute(sql, values)

                # Dodanie danych do tabeli Reservation Services
                if key == "reservations":
                    for service_id in item.get("services", []):
                        try:
                            cursor.execute(
                                """
                              INSERT INTO reservation_services (reservation_id, service_id)
                              VALUES (%s, %s)
                              ON DUPLICATE KEY UPDATE reservation_id = reservation_id;
                              """,
                                (item["id"], service_id),
                            )
                        except Exception as e:
                            print(f"Błąd dodawania do reservation_services: {e}")

        connection.commit()
        print("Dane zostały poprawnie zapisane do bazy danych.\n")

    except Exception as e:
        print(f"Wystąpił błąd: {e}")

connection.close()
print("Połączenie z bazą danych zostało zamknięte.")
