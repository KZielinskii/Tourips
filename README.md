# Tourpis

System mobilny w technologiach Flutter i Firebase do organizacji wycieczek turystycznych.

## Architektura aplikacji

W rozważaniach nad architekturą aplikacji kluczowym aspektem jest skuteczna organizacja procesu komunikacji pomiędzy różnymi elementami systemu. 
W schemacie blokowym systemu zobrazowano proces komunikacji pomiędzy Interfejsem Użytkownika (UI) a bazą danych, a także zewnętrznymi interfejsami programowania aplikacji (API) takimi jak Google Maps i Stripe.
W ramach tej aplikacji zaimplementowano architekturę ModelView-ViewModel (MVVM), co umożliwia efektywne oddzielenie warstw odpowiedzialnych za prezentację danych, logikę biznesową i zarządzanie danymi.

## Wzorzec projektowy

W procesie tworzenia aplikacji Flutter zdecydowałem się zastosować wzorzec projektowy MVVM (Model-View-ViewModel). 
Wzorzec ten skupia się na wyraźnym podziale między logiką biznesową, reprezentowaną przez modele, a warstwą prezentacji, zorganizowaną za pomocą widoków (Views) i modeli widoku (ViewModels). 
MVVM umożliwia efektywne zarządzanie danymi, dostarczanie ich do interfejsu użytkownika oraz obsługę interakcji użytkownika, przy jednoczesnym utrzymaniu klarownego i modułowego kodu.


