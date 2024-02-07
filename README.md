# Tourips - System mobilny w technologiach Flutter i Firebase do organizacji wycieczek turystycznych.

## Architektura aplikacji

W rozważaniach nad architekturą aplikacji kluczowym aspektem jest skuteczna organizacja procesu komunikacji pomiędzy różnymi elementami systemu. 
W schemacie blokowym systemu zobrazowano proces komunikacji pomiędzy Interfejsem Użytkownika (UI) a bazą danych, a także zewnętrznymi interfejsami programowania aplikacji (API) takimi jak Google Maps i Stripe.
W ramach tej aplikacji zaimplementowano architekturę Model-View-ViewModel (MVVM), co umożliwia efektywne oddzielenie warstw odpowiedzialnych za prezentację danych, logikę biznesową i zarządzanie danymi.

## Wzorzec projektowy

W procesie tworzenia aplikacji Flutter zdecydowałem się zastosować wzorzec projektowy MVVM (Model-View-ViewModel). 
Wzorzec ten skupia się na wyraźnym podziale między logiką biznesową, reprezentowaną przez modele, a warstwą prezentacji, zorganizowaną za pomocą widoków (Views) i modeli widoku (ViewModels). 
MVVM umożliwia efektywne zarządzanie danymi, dostarczanie ich do interfejsu użytkownika oraz obsługę interakcji użytkownika, przy jednoczesnym utrzymaniu klarownego i modułowego kodu.

## Część serwerowa

Cloud Firestore, jako skalowalna baza danych NoSQL, została zintegrowana z projektem Flutter. 
Wykorzystano ją do przechowywania danych użytkowników, wydarzeń i innych informacji w bazie danych.
Skonfigurowano i połączono aplikację Flutter z bazą danych Firestore.
Utworzono odpowiednie kolekcje i dokumenty do przechowywania danych związanych z użytkownikami i innymi elementami aplikacji. Poniżej przedstawiono schemat bazy danych zaimplementowany w aplikacji:
1. chat_rooms - Kolekcja odpowiedzialna za przechowywanie danych dotyczących czatu między użytkownikami.
2. event_participants - Kolekcja przechowująca identyfikatory uczestników wydarzeń.
3. event_requests - Kolekcja przechowująca prośby o dołączenie do konkretnego wydarzenia.
4. events - Kolekcja zawierająca główne informacje o wydarzeniach.
5. friends - Kolekcja przechowująca listę identyfikatorów użytkowników, którzy są znajomymi.
6. payments - Kolekcja przechowująca informacje o wydatkach związanych z wydarzeniem, takie jak tytuł, osoba płacąca, osoby, z którymi rachunek jest do podziału, oraz kwota.
7. requests - Kolekcja przechowująca wysłane zaproszenia do znajomych.
8. stripe_customers - Kolekcja przechowująca aktualny stan konta użytkowników na platformie Stripe.
9. users - Kolekcja zawierająca informacje o użytkownikach.

## Implementacja

### Logowanie i rejestracja użytkowników

Ekran logowania (SignInScreen) dostarcza użytkownikowi interaktywnego oraz estetycznego interfejsu umożliwiającego wprowadzanie danych logowania oraz nawigację do rejestracji w przypadku braku konta. 
Ponadto udostępnia różnorodne funkcjonalności, takie jak: 
• Indykator ładowania - W sytuacji, gdy aplikacja jest zajęta operacją logowania, użytkownikowi ukazuje się indykator ładowania (CircularProgressIndicator), informujący o trwającym procesie.
• Przycisk Logowania - Pozwala na przesłanie żądania logowania do Firebase z użyciem dostarczonych danych. Po pomyślnym zalogowaniu, użytkownik zostaje przekierowany do ekranu domowego (HomeScreen).
• Obsługa błędów - W przypadku podania błędnych danych logowania, użytkownikowi prezentowany jest komunikat o błędzie za pomocą snackbar.

![Zrzut ekranu 2024-01-23 175515](https://github.com/KZielinskii/Tourips/assets/58587948/72fcea1c-eedf-4eea-b720-8b6c56fcf21a)

Ekran rejestracji (SignUpScreen) stanowi interaktywny interfejs użytkownika, który umożliwia wprowadzenie niezbędnych informacji potrzebnych do stworzenia nowego konta oraz nawigację do logowania w przypadku posiadania konta. 
Poniżej przedstawiono krótki opis funkcji tego ekranu:
• Formularz rejestracji - Ekran zawiera formularz rejestracji, w którym użytkownik może wprowadzić swój login, adres e-mail oraz hasło. Ponadto istnieje pole do potwierdzenia hasła.
• Przycisk rejestracji - Przycisk rejestracji umożliwia wysłanie żądania utworzenia nowego konta do Firebase. Po pomyślnym utworzeniu konta użytkownik jest przekierowywany do ekranu domowego (HomeScreen).
• Indykator ładowania - W przypadku trwającej operacji rejestracji, wyświetlany jest indykator ładowania (CircularProgressIndicator), informujący użytkownika o trwającym procesie.
• Walidacja hasła - Przed wysłaniem żądania rejestracji, ekran przeprowadza walidację wprowadzonego hasła pod kątem poprawności, takiej jak długość, zgodność, obecność cyfr i znaków specjalnych.
• Obsługa błędów - W przypadku błędnych danych rejestracyjnych, użytkownikowi prezentowany jest komunikat o błędzie poprzez snackbar.

![Zrzut ekranu 2024-01-23 175617](https://github.com/KZielinskii/Tourips/assets/58587948/34ad9dda-c854-4571-be78-75f6fd00a10a)

###  Integracja metod płatności

Ekran PaymentHomeScreen to interaktywny interfejs użytkownika, który dostarcza interfejs do efektywnego zarządzania płatnościami związanych z wycieczką, umożliwiając użytkownikowi łatwą nawigację między listą płatności a bilansem, a także dodawanie nowych płatności za pomocą przejścia do ekranu AddPaymentScreen. 
Estetyczne gradientowe tło i spójna kolorystyka tworzą atrakcyjne wrażenie wizualne. Poniżej przedstawiono krótki opis funkcji tego ekranu:
• AppBar - Górna belka nawigacyjna zawiera tytuł "Podział wydatków" oraz przyjemny gradient kolorów, co nadaje estetyczny wygląd.
• BottomNavigationBar - Dolna nawigacja zawiera dwie ikony: "Wydatki" i "Bilans". Użytkownik może przełączać się między zakładkami, aby wyświetlać listę płatności (PaymentScreen) lub bilans (BalanceScreen). Aktualnie wybrana zakładka jest podświetlona.
• Body - Główna treść ekranu to stosowane gradientowe tło, które zawiera jedną z dwóch zawartości w zależności od wybranej zakładki: lista płatności lub bilans. Zawartość ta jest dynamicznie renderowana na podstawie _selectedIndex, który jest aktualizowany przy zmianie zakładki.
• FloatingActionButton - Przycisk "plus" umożliwia dodawanie nowych płatności.Po naciśnięciu przycisku otwiera się ekran AddPaymentScreen, gdzie użytkownik może wprowadzić nowe informacje dotyczące płatności związanej z wydarzeniem.

Ekran płatności (PaymentScreen) to interaktywny interfejs użytkownika, który został zaimplementowany w sposób umożliwiający interaktywne zarządzanie płatnościami związanych z wycieczkami, zapewniając jednocześnie intuicyjny interfejs użytkownika. 
Poniżej przedstawiono krótki opis funkcji tego ekranu:
• Lista płatności - Ekran prezentuje listę płatności związanych z konkretnym wydarzeniem. Każda pozycja na liście zawiera informacje, takie jak tytuł płatności, login użytkownika dokonującego płatności, kwota oraz opcję usunięcia wpisu poprzez przytrzymanie.
• Aktualizacja listy - Użytkownik może odświeżyć listę płatności, przeciągając w dół ekranu. To powoduje ponowne pobranie i wyświetlenie najnowszych danych dotyczących płatności.
• Widok ładowania - Podczas ładowania danych, ekran wyświetla animowany wskaźnik postępu (CircularProgressIndicator) informujący użytkownika o trwającym procesie.
• Asynchroniczne operacje - Pobieranie danych i operacje związane z interakcjami użytkownika są obsługiwane asynchronicznie, zapewniając płynne i responsywne doświadczenie.
• Informacje wstępne - Po załadowaniu listy, użytkownikowi prezentowany jest komunikat w postaci snackbar, informujący go o dostępnej opcji usuwania wpisów poprzez przytrzymanie.

![Zrzut ekranu 2024-01-24 160442](https://github.com/KZielinskii/Tourips/assets/58587948/69e047f0-78f6-4de1-a829-824b59e1e846)

Ekran BalanceScreen to interaktywny interfejs użytkownika skoncentrowany na wyświetlaniu salda płatności pomiędzy uczestnikami danego wydarzenia, który dostarcza użytkownikowi narzędzi do śledzenia i rozliczania sald płatności między uczestnikami wydarzenia, co pomaga w utrzymaniu przejrzystości i uczciwości finansowej w kontekście organizowanych wycieczek. Poniżej przedstawiono krótki opis funkcji tego ekranu:
• Lista Sald Uczestników - Ekran prezentuje listę uczestników wydarzenia wraz z ich saldami, które wynikają z różnic pomiędzy kwotami, jakie dany uczestnik już wpłacił, a tym, ile jeszcze powinien wpłacić. Salda są wyświetlane w postaci listy elementów interfejsu (PaymentListItem), gdzie każdy element przedstawia informacje takie jak nazwa użytkownika, aktualne saldo oraz kolor. Kolor czerwony oznacza konieczność spłaty długu wobec innych użytkowników, a kolor zielony w przeciwieństwie do czerwonego nie wymaga żadnych działań od użytkownika.
• Odświeżanie Listy - Użytkownik może odświeżyć listę, przeciągając w dół ekranu. To spowoduje ponowne pobranie i wyświetlenie najnowszych danych dotyczących sald uczestników.
• Przycisk "Zapłać" - Przycisk ten umożliwia użytkownikowi rozliczenie się z innymi uczestnikami wydarzenia. Po jego naciśnięciu, wywoływana jest funkcja stripeMakePayment(), która inicjuje płatność przy użyciu platformy Stripe.
• Płatność przy użyciu Stripe - Funkcja stripeMakePayment() wykorzystuje bibliotekę Flutter Stripe do inicjacji płatności. Użytkownik jest przekierowywany do ekranu płatności, gdzie może dokonać transakcji.
• Rozliczanie Sald - Po udanej płatności, wywoływana jest funkcja findAndPayUsers(), która sprawdza salda uczestników i rozlicza wpłaty, przy użyciu funkcji topUpBalance oraz giveMoneyToUser związanych z platformą Stripe.
• Usuwanie Długu - Funkcja removeDebt służy do utworzenia nowego wpisu w historii płatności (PaymentsRepository), informującego o zwrocie kosztów. To pozwala na zaktualizowanie listy sald na ekranie.

![Zrzut ekranu 2024-01-24 162104](https://github.com/KZielinskii/Tourips/assets/58587948/fb20ad8d-114c-4094-ae4c-7c9345734ac6)
![Zrzut ekranu 2024-01-24 162220](https://github.com/KZielinskii/Tourips/assets/58587948/c7555bed-8f73-4229-8281-022cbea5da12)
![Zrzut ekranu 2024-01-24 163025](https://github.com/KZielinskii/Tourips/assets/58587948/2ee1571b-f37e-48c6-b880-0da1a721bf8d)
![Zrzut ekranu 2024-01-24 163039](https://github.com/KZielinskii/Tourips/assets/58587948/1046f51f-7bd5-4d22-848f-ed7d22d9355f)

Ekran AddPaymentScreen to interaktywny interfejs użytkownika, który dostarcza użytkownikowi intuicyjny sposób na dodawanie nowych płatności związanych z organizowanym wydarzeniem, jednocześnie dbając o walidację wprowadzonych danych i prezentację komunikatów błędów. Poniżej przedstawiono krótki opis funkcji tego ekranu:
• Formularz Dodawania Płatności - Ekran zawiera formularz, który umożliwia użytkownikowi wprowadzenie danych dotyczących nowej płatności, takich jak tytuł, kwota oraz wybór uczestników, którzy ponoszą koszty. Formularz ten składa się z pól tekstowych (TextField) oraz rozwijanej listy (ExpansionTile) do wyboru uczestników.
• Walidacja Danych - Przed dodaniem płatności, ekran sprawdza poprawność wprowadzonych danych. Walidacja obejmuje sprawdzenie czy pola tytułu i kwoty są wypełnione oraz czy wybrano przynajmniej jednego uczestnika. W przypadku błędnych danych, użytkownikowi prezentowany jest komunikat o błędzie.
• Lista Uczestników - Lista uczestników wydarzenia jest dynamicznie pobierana z repozytorium (EventParticipantsRepository). Użytkownik może zaznaczyć uczestników, którzy biorą udział w danej płatności.
• Floating Action Button - Przycisk "check" w rogu ekranu umożliwia użytkownikowi potwierdzenie wprowadzonych danych i dodanie nowej płatności do systemu.
• Komunikaty Snackbar - W przypadku błędnych danych lub problemów podczas dodawania płatności, ekran wykorzystuje funkcje createSnackBarError do wyświetlania komunikatów typu Snackbar, informujących użytkownika o błędach.
• Obsługa Formatu Kwoty - W przypadku, gdy kwota zawiera przecinek, zostaje on zastąpiony kropką, aby zapewnić poprawne parsowanie jako liczby zmiennoprzecinkowej.

![Zrzut ekranu 2024-01-24 172655](https://github.com/KZielinskii/Tourips/assets/58587948/b0085684-d83c-4d10-9058-e7f55f869862)

### Integracja aplikacji z mapami google

Ekran MapScreen stanowi interaktywny interfejs użytkownika, który umożliwia użytkownikowi dodawanie tras związanych z organizowanym wydarzeniem, zapewniając jednocześnie prosty interfejs do interakcji z mapą Google. Poniżej przedstawiono krótki opis funkcji tego ekranu:
• Mapa Google - Zapewnia interaktywną mapę Google, na której użytkownik może dodawać punkty trasy.
• Dodawanie Punktów Trasy - Poprzez naciśnięcie na mapie, użytkownik może dodawać punkty trasy, które są reprezentowane jako markery. Każdy punkt trasy zawiera informacje o najbliższej atrakcji w pobliżu, dostępne dzięki API Google Places.
• Usuwanie Punktów Trasy - Użytkownik może usuwać ostatnio dodane punkty trasy za pomocą przycisku "Usuń".
• Obliczanie Optymalnej Trasy - Aplikacja wykorzystuje bibliotekę flutter_polyline_points do dynamicznego obliczania optymalnej trasy, uwzględniającej kolejność punktów na mapie. Użytkownik może zoptymalizować trasę, co pozwala na bardziej efektywne planowanie podróży w oparciu o dostępne punkty na mapie.
• Zapisywanie Trasy - Po zaznaczeniu interesującej trasy, użytkownik może ją zapisać, naciskając przycisk "Zapisz".
• Dynamiczna Aktualizacja Lokalizacji - Okresowo aktualizuje lokalizację użytkownika na mapie, umożliwiając śledzenie bieżącej pozycji.
• Informacje o Atrakcjach - Dla każdego dodanego punktu trasy prezentuje nazwę najbliższej atrakcji, dzięki czemu użytkownik może lepiej zorientować się w okolicy.
• Prosty Interfejs Użytkownika - Interfejs jest zaprojektowany w sposób intuicyjny, umożliwiając łatwe dodawanie, usuwanie i zapisywanie tras.

![Zrzut ekranu 2024-01-24 184045](https://github.com/KZielinskii/Tourips/assets/58587948/a84c710b-ad4a-4adf-920d-8e5b1f07f171)

Ekran edycji EditMapScreen działa na tej samej zasadzie co ekran dodawania mapy, jednak na początku ładowana jest zapisana trasa z bazy danych związana z wybranym wydarzeniem. Poniżej przedstawiono krótki opis funkcji tego ekranu:
• Ładowanie Trasy z Bazy Danych - Ekran automatycznie wczytuje trasę związana z wydarzeniem, umożliwiając edycję punktów trasy.
• Edycja Punktów Trasy - Użytkownik może modyfikować istniejące punkty trasy oraz dodawać nowe punkty, korzystając z interaktywnej mapy Google.
• Usuwanie Punktów Trasy - Analogicznie do ekranu dodawania mapy, użytkownik ma możliwość usuwania ostatnio dodanych punktów trasy.
• Zapisywanie Zmodyfikowanej Trasy - Po wprowadzeniu zmian, użytkownik może zapisać zaktualizowaną trasę do wybranego wydarzenia.
• Dynamiczna Aktualizacja Lokalizacji - Posiada dynamiczną aktualizację lokalizacji użytkownika, co pozwala na bieżące śledzenie pozycji na mapie.
• Informacje o Atrakcjach - Dla każdego punktu trasy prezentowane są informacje o najbliższej atrakcji, dostarczane przez API Google Places.
• Prosty Interfejs Użytkownika - Interfejs jest zaprojektowany w sposób intuicyjny, umożliwiając łatwą edycję i zapisywanie tras.

Ekran DisplayMapScreen umożliwia użytkownikowi interaktywne przeglądanie zapisanej trasy na mapie. Poniżej przedstawiono kluczowe funkcje tego ekranu:
• Mapa Trasy - Ekran wykorzystuje widżet GoogleMap do wyświetlania trasy składającej się z punktów trasowania zapisanych w formie listy LatLng.
• Aktualna Lokalizacja - Aplikacja monitoruje aktualną lokalizację użytkownika, a uzyskane dane są wykorzystywane do umieszczenia znacznika na mapie w miejscu, gdzie znajduje się obecnie użytkownik.
• Przesuwanie do Aktualnej Lokalizacji - Przycisk "my_location" Floating Action Button pozwala na łatwe przemieszczenie mapy do aktualnej lokalizacji użytkownika.
• Zmiana Lokalizacji - W przypadku zmiany lokalizacji użytkownika, mapa automatycznie aktualizuje położenie znacznika na mapie, co umożliwia śledzenie ruchu użytkownika.
• Marker Punktów Trasy - Każdy punkt trasy jest oznaczony na mapie przy użyciu markerów, które zawierają informacje o danym punkcie, takie jak tytuł czy nazwa lokalizacji.
• Pobieranie Informacji o Trasie - W przypadku każdego punktu trasy aplikacja wykorzystuje bibliotekę flutter_polyline_points, aby dynamicznie obliczyć i narysować optymalną trasę na mapie.
• Dynamiczne Odświeżanie Lokalizacji - Aktualna lokalizacja użytkownika jest dynamicznie odświeżana co sekundę, co umożliwia płynne śledzenie ruchu.


![Zrzut ekranu 2024-01-24 195419](https://github.com/KZielinskii/Tourips/assets/58587948/ba923cab-4889-44f1-8f22-d6a8d2fe2849)
![Zrzut ekranu 2024-01-24 195429](https://github.com/KZielinskii/Tourips/assets/58587948/18e2eed1-195d-4029-811e-4eb69b541394)

### Czat ze znajomymi

W celu dodania użytkownika do listy znajomych, konieczne jest rozwinięcie menu, a następnie wybranie opcji "Dodaj znajomych". W rezultacie pojawi się ekran z dwoma zakładkami: "Użytkownicy" oraz "Zaproszenia".Zakładka "Użytkownicy" wyświetla ekran "SearchUsersFragment" reprezentujący interaktywny fragment interfejsu użytkownika, który umożliwia użytkownikowi wyszukiwanie i przeglądanie listy użytkowników dostępnych w aplikacji. Poniżej przedstawiono kluczowe elementy i funkcje tego ekranu:
• Pole Wyszukiwania - Na górze ekranu znajduje się pole wyszukiwania umieszczone w pasku nawigacyjnym. Użytkownik może wprowadzać zapytania w tym polu w celu filtrowania listy użytkowników według ich nazw użytkownika (loginów). Wprowadzanie tekstu w polu automatycznie aktualizuje listę użytkowników w czasie rzeczywistym.
• Lista Użytkowników - Poniżej pola wyszukiwania znajduje się lista użytkowników, której zawartość dynamicznie dostosowuje się do wyników wyszukiwania. Każdy element listy reprezentuje jednego użytkownika. Informacje o użytkowniku są prezentowane w formie "UserListItem", który zawiera istotne szczegóły o użytkowniku, takie jak avatar i nazwa użytkownika, a także przycisk zaproszenia do znajomych.
• Inicjalizacja Listy - Podczas inicjalizacji ekranu, lista wszystkich użytkowników (oprócz znajomych i osób do których zaproszenie już zostało wysłane) jest pobierana za pomocą UserRepository. W trakcie tej inicjalizacji aplikacja wykorzystuje wsparcie dla ładowania (loading indicator), który informuje użytkownika o trwającym procesie pobierania danych.
• Aktualizacja Listy po Wyszukiwaniu - Dane są automatycznie filtrowane na podstawie wprowadzonego zapytania w polu wyszukiwania. Funkcja _updateFilteredUsersList odpowiada za aktualizację listy użytkowników na podstawie aktualnego zapytania wprowadzonego przez użytkownika.
• Responsywność - Projektowanie ekranu uwzględnia responsywność, a więc dostosowanie do różnych rozmiarów ekranów urządzeń mobilnych.

![Zrzut ekranu 2024-01-24 201246](https://github.com/KZielinskii/Tourips/assets/58587948/87f37b62-673f-46c3-855d-99632105b6ef)


