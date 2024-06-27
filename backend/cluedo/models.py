from django.db import models

from cluedo import settings

class FileField(models.FileField):
    def value_to_string(self,obj):
        return obj.file.url

class Player(models.Model):
    number = models.IntegerField(primary_key=True)
    name = models.CharField(max_length = 30)
    password = models.CharField(max_length=20)
    pic = FileField(null=True,blank=True,default='default.jpg')
    wins = models.IntegerField(default = 0)
    loss = models.IntegerField(default = 0)
    def __str__(self) -> str:
        return self.name

class Lobby(models.Model):
    code = models.CharField(primary_key = True,max_length = 10)
    host = models.ForeignKey(Player, on_delete=models.CASCADE, related_name = "host")
    status = models.CharField(max_length=30, choices=[
        ('open', 'Open'),
        ('closed', 'Closed'),
        ('ongoing', 'Ongoing'),
        ('finished', 'Finished'),
    ], default='open')
    players = models.ManyToManyField(Player, blank=True, related_name='players_lobby') 
    winner = models.ForeignKey(Player, blank=True, null=True, on_delete=models.PROTECT, related_name='won_game')  
    turn = models.IntegerField()
    answer = models.ManyToManyField("Cards", related_name="lobby_answers")

    def __str__(self) -> str:
        return self.code
    
class GamePlayer(models.Model):
    userid = models.ForeignKey(Player, null=False, on_delete=models.CASCADE,)
    character = models.CharField(max_length=1, null=False)
    gameid = models.ForeignKey(Lobby, null=False, on_delete=models.CASCADE,)
    cards = models.ManyToManyField("Cards", related_name="card_stack")

class Cards(models.Model):
    card = models.CharField(default="",max_length=100)
    cardtype = models.CharField(max_length=30, choices=[
        ('s', 'suspects'),
        ('w', 'weapons'),
        ('r', 'room'),
    ], default='s')
    
    def __str__(self) -> str:
        return str(self.pk)+" " + self.card
    
