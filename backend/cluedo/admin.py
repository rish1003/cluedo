from django.contrib import admin

from cluedo.models import GamePlayer, Player, Lobby, Cards

# Register your models here.
admin.site.register(Player)
admin.site.register(Lobby)
admin.site.register(Cards)
admin.site.register(GamePlayer)