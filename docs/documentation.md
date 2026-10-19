# Geome Explore – Dokumentacja projektu

## 1. Opis projektu

Geome Explore to aplikacja mobilna służąca do odkrywania miast na podstawie doświadczeń i opinii innych użytkowników.

Główną ideą projektu jest możliwość tworzenia tematycznych zbiorów miejsc w formie wpisów przypominających playlisty. Autor może wybrać miasto, dodać miejsca w określonej kolejności oraz opisać swoje doświadczenia związane z każdym z nich. Wpisy mogą zawierać zarówno rekomendacje, jak i negatywne opinie.

Pozostali użytkownicy mogą przeglądać i zapisywać takie zbiory, aby łatwiej planować zwiedzanie. Aplikacja ma stanowić alternatywę dla czasochłonnego wyszukiwania rekomendacji w mediach społecznościowych.

Istotnym elementem aplikacji będzie personalizacja propozycji zwiedzania z uwzględnieniem indywidualnych preferencji i ograniczeń czasowych użytkownika. Dzięki temu użytkownik będzie mógł odkrywać miejsca i gotowe propozycje ich odwiedzenia, dopasowane do swoich zainteresowań oraz czasu, którym dysponuje.

## 2. Wymagania funkcjonalne

### 2.1. Konta użytkowników

- Rejestracja nowego użytkownika.
- Logowanie i wylogowywanie.
- Przeglądanie własnego profilu.
- Wyświetlanie opublikowanych i zapisanych wpisów.

### 2.2. Tworzenie i zarządzanie wpisami

- Tworzenie nowego wpisu przypisanego do wybranego miasta.
- Nadawanie wpisowi tytułu i kategorii.
- Dodawanie ogólnego opisu wpisu.
- Dodawanie miejsc w określonej kolejności.
- Dodawanie własnych opisów i opinii do poszczególnych miejsc.
- Zmiana kolejności miejsc.
- Określanie szacowanego czasu potrzebnego na odwiedzenie miejsc.
- Edytowanie i usuwanie własnych wpisów.
- Publikowanie wpisów, aby były dostępne dla innych użytkowników.

Wpis nie musi przedstawiać wyłącznie rekomendowanych miejsc. Może zawierać również subiektywne opinie, porównania i negatywne doświadczenia.

### 2.3. Przeglądanie i zapisywanie wpisów

- Przeglądanie wpisów opublikowanych przez innych użytkowników.
- Wyświetlanie szczegółów wpisu wraz z uporządkowaną listą miejsc i opisami.
- Zapisywanie wybranych wpisów we własnej kolekcji.
- Usuwanie wpisów z zapisanej kolekcji.
- Przechodzenie do informacji o miejscach powiązanych z wpisem.

### 2.4. Miasta i miejsca

- Przeglądanie stron miast zawierających podstawowe informacje i powiązane wpisy.
- Wyszukiwanie miejsc podczas tworzenia wpisu.
- Wyświetlanie podstawowych informacji o miejscu, np. nazwy i adresu.
- Powiązanie jednego miejsca z wieloma wpisami różnych użytkowników.

### 2.5. Wyszukiwanie i filtrowanie

- Wyszukiwanie wpisów według miasta.
- Filtrowanie według kategorii.
- Filtrowanie według szacowanego czasu zwiedzania.
- Łączenie kilku kryteriów wyszukiwania.

W pierwszej wersji czas zwiedzania będzie wartością szacunkową przypisaną do wpisu, bez automatycznego wyznaczania optymalnej trasy.

## 3. Funkcjonalności dodatkowe

Poniższe funkcje mogą zostać zrealizowane w zależności od dostępnego czasu:

- Oznaczanie odwiedzonych miast i miejsc.
- Wyświetlanie statystyk odwiedzonych miast i miejsc w profilu.
- Komentowanie wpisów innych użytkowników.
- Integracja z Google Places API w celu wyszukiwania lokalizacji i pobierania ich danych.
- Prezentacja miejsc na mapie.

## 4. Wymagania niefunkcjonalne

- **Platforma:** aplikacja mobilna przeznaczona na system Android, rozwijana z wykorzystaniem Fluttera.
- **Przechowywanie danych:** centralna baza danych umożliwiająca synchronizację wpisów i zapisanych kolekcji między urządzeniami.
- **Bezpieczeństwo:** uwierzytelnianie użytkowników oraz kontrola dostępu do danych na poziomie backendu (Row Level Security).
- **Komunikacja:** asynchroniczna wymiana danych między aplikacją a backendem.
- **Architektura:** oddzielenie interfejsu użytkownika od logiki aplikacji i warstwy dostępu do danych.

## 5. Projekt interfejsu użytkownika

### 5.1. Ekrany podstawowe

#### 5.1.1. Strona miasta (ekran główny)

Główny ekran aplikacji, dostępny również bez logowania.

- Nazwa, zdjęcie i podstawowe informacje o wybranym mieście.
- Możliwość wyszukania i zmiany miasta.
- Wyświetlanie najpopularniejszych wpisów dotyczących miasta, na podstawie liczby zapisów przez użytkowników.
- Przejście do pełnej listy wpisów dotyczących miasta.
- Przejście do szczegółów wybranego wpisu.

Przy pierwszym uruchomieniu użytkownik wybiera miasto. Przy kolejnych uruchomieniach aplikacja wyświetla ostatnio wybrane miasto.

#### 5.1.2. Rejestracja

- Formularz tworzenia nowego konta.
- Przejście do ekranu logowania.

Rejestracja nie jest wymagana do przeglądania publicznej zawartości aplikacji.

#### 5.1.3. Logowanie

- Formularz logowania do istniejącego konta.
- Przejście do ekranu rejestracji.

Logowanie jest wymagane przy próbie skorzystania z funkcji związanych z kontem użytkownika, np. tworzenia lub zapisywania wpisów.

#### 5.1.4. Profil użytkownika

- Podstawowe informacje o użytkowniku.
- Lista opublikowanych wpisów.
- Dostęp do zapisanych wpisów.
- Możliwość wylogowania.

Dla niezalogowanego użytkownika zamiast profilu wyświetlana jest możliwość zalogowania lub rejestracji.

#### 5.1.5. Tworzenie i edycja wpisu

Ekran umożliwiający:

- Wybór miasta, którego dotyczy wpis.
- Wprowadzenie tytułu.
- Wybór jednej lub kilku kategorii.
- Dodanie opcjonalnego opisu całego wpisu.
- Wyszukiwanie i dodawanie miejsc w określonej kolejności.
- Dodawanie własnych opisów i opinii do poszczególnych miejsc.
- Zmianę kolejności dodanych miejsc.
- Usuwanie miejsc z wpisu.
- Określenie szacowanego czasu potrzebnego na odwiedzenie miejsc.
- Zapisanie i opublikowanie wpisu.

Ten sam formularz będzie wykorzystywany do edycji istniejących wpisów. Tworzenie i edycja są dostępne wyłącznie dla zalogowanych użytkowników.

#### 5.1.6. Lista wpisów

Ekran umożliwiający przeglądanie wpisów w trzech trybach:

- **Wszystkie** – publiczne wpisy opublikowane przez użytkowników.
- **Moje** – wpisy utworzone przez zalogowanego użytkownika, z możliwością edycji i usunięcia.
- **Zapisane** – wpisy zapisane przez użytkownika, z możliwością usunięcia ich z własnej kolekcji.

Dodatkowo:

- Wyszukiwanie wpisów według miasta.
- Filtrowanie według jednej lub kilku kategorii.
- Filtrowanie według dostępnego czasu zwiedzania.
- Łączenie kryteriów wyszukiwania.
- Przejście do szczegółów wybranego wpisu.
- Przycisk tworzenia nowego wpisu.

Tryb „Wszystkie” jest dostępny bez logowania. Pozostałe tryby wymagają zalogowania.

#### 5.1.7. Szczegóły wpisu

- Tytuł, kategorie i opis wpisu.
- Informacje o autorze i mieście.
- Szacowany czas zwiedzania.
- Lista miejsc w kolejności określonej przez autora.
- Opisy i opinie przypisane do poszczególnych miejsc.
- Możliwość otwarcia wybranego miejsca w Google Maps.
- Możliwość zapisania wpisu lub usunięcia go z zapisanych.
- Przejście do strony miasta.

Przeglądanie wpisu jest dostępne bez logowania. Zapisywanie wymaga zalogowania.

### 5.2. Ekrany i funkcjonalności dodatkowe

#### 5.2.1. Szczegóły miejsca

- Nazwa, adres i podstawowe informacje o miejscu.
- Lista wpisów, w których pojawia się dane miejsce.
- Możliwość otwarcia lokalizacji w Google Maps.

#### 5.2.2. Odwiedzone miejsca i miasta

- Oznaczanie miejsc i miast jako odwiedzonych.
- Przeglądanie listy odwiedzonych miejsc i miast.
- Wyświetlanie statystyk odwiedzonych miast i miejsc w profilu użytkownika.

#### 5.2.3. Komentarze

- Przeglądanie komentarzy pod wpisami.
- Dodawanie komentarzy przez zalogowanych użytkowników.
- Usuwanie własnych komentarzy.

### 5.3. Nawigacja aplikacji

Głównym ekranem aplikacji będzie strona wybranego miasta. Przeglądanie miast, miejsc i publicznych wpisów nie będzie wymagało logowania.

Ekrany logowania i rejestracji będą dostępne z poziomu aplikacji oraz przy próbie wykonania czynności wymagającej uwierzytelnienia.

### 5.4. Projekty graficzne

## 6. Architektura aplikacji

## 7. Model bazy danych

## 8. Implementacja

## 9. Testowanie

## 10. Podsumowanie

*Do uzupełnienia po zakończeniu projektu – osiągnięte rezultaty, ograniczenia i możliwości dalszego rozwoju.*
