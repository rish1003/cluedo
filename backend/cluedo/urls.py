"""
URL configuration for cluedo project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from cluedo.views import *

urlpatterns = [
    path('admin/', admin.site.urls),
    path('register/', register_user),
    path('login/<int:number>/<str:password>/', login_user),
    path('get_user_details/<int:id>/', get_user_details),
    path('create_lobby/<int:id>/<int:char>/', create_lobby),
    path('close_lobby/<int:id>/', close_lobby),
    path('get_lobby_details/<int:id>/', get_lobby_details),
    path('join_lobby/<int:id>/<str:codes>/<int:char>/', join_lobby),
    path('leave_lobby/<int:id>/<str:codes>/', leave_lobby),
    path('get_chars/<str:codes>/', get_chosen_characters),
    path('get_lobby_chars/<str:codes>/', get_lobby_players_and_characters),
    path('status/<str:codes>/', check_game_status),
    path('changeturn/<str:lobby_code>/',change_turn),
    path('checkturn/<str:lobby_code>/<int:player_number>/',check_user_turn),
    path('getcharsofplay/<str:lobby_code>/',all_player_characters),
    path('start_game/<str:codes>/',start_game),
    path('get_playerstack/<int:player_id>/',get_player_card_stack),
    path('answer/<str:codes>/<int:suspect_card_id>/<int:weapon_card_id>/<int:room_card_id>/',compare_cards),
    path('pop_server/<str:codes>/',populate_players_and_options)
    
]
