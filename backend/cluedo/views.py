# views.py
from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from .models import Cards, GamePlayer, Lobby, Player
from .serializers import LobbySerializer, PlayerSerializer
from django.contrib.auth.hashers import make_password, check_password
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .serializers import LobbySerializer  # Import your LobbySerializer
import random
import string
from random import sample
from django.db import transaction

CLUEDO_CHARACTERS = {
    0: "Professor Plum",
    1: "Reverend Green",
    2: "Colonel Mustard",
    3: "Mrs. Peacock",
    4: "Miss Scarlet",
    5: "Mrs. White",
}


def generate_random_word(length=5):
    letters = string.ascii_lowercase
    random_word = ''.join(random.choice(letters) for _ in range(length))
    return random_word

@api_view(['POST'])
def register_user(request):
    serializer = PlayerSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(password=make_password(request.data['password']))
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def login_user(request,number,password):
   
    try:
        player = Player.objects.get(number=number)
    except Player.DoesNotExist:
        return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

    if check_password(password, player.password):
        serializer = PlayerSerializer(player)
        return Response(serializer.data, status=status.HTTP_200_OK)
    else:
        return Response({'error': 'Incorrect credentials'}, status=status.HTTP_401_UNAUTHORIZED)

@api_view(['GET'])
def get_user_details(request,id):
    player = Player.objects.get(number=id)
    if player:
        serializer = PlayerSerializer(player)
        return Response({'User':serializer.data},status=status.HTTP_200_OK)
    else:
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
def create_lobby(request, id,char):
    try:
        existing_lobby = Lobby.objects.get(host=Player.objects.get(number=id))
        return Response({'error': 'Host already has a lobby'}, status=status.HTTP_400_BAD_REQUEST)
    except Lobby.DoesNotExist:
        for i in range(5):
            codes = generate_random_word()
            try:
                lobby_with_code = Lobby.objects.get(code=codes)
                continue
            except Lobby.DoesNotExist:
                player = Player.objects.get(number=id)
                lobby = Lobby.objects.create(
                    code=codes,
                    host=player,
                    turn = player.number
                )
                lobby.players.set([player])
                lobby.save()
                newGamePlayer = GamePlayer(userid=player,gameid=lobby,character = char)
                newGamePlayer.save()
                return Response({"message": codes}, status=status.HTTP_200_OK)
        return Response({'error': 'Lobby not created'}, status=status.HTTP_408_REQUEST_TIMEOUT)
    
@api_view(['POST'])
def close_lobby(request,id):
    lobby = Lobby.objects.get(host = Player.objects.get(number=id) )
    lobby.delete()
    return Response({'message':'Deleted Lobby'},status=status.HTTP_200_OK)

@api_view(['GET'])
def get_lobby_details(request,id):
    try:
        lobby = Lobby.objects.get(host = Player.objects.get(number=id) )
        serializer = LobbySerializer(lobby)
        return Response({'data':serializer.data})
    except:
        return Response({'error': 'Lobby does not exist'}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def join_lobby(request, id, codes, char):
    try:
        player = Player.objects.get(number=id)
        lobby = Lobby.objects.get(code=codes)

        if lobby.status != "open":
            return Response({'error': 'Lobby is not open'}, status=status.HTTP_403_FORBIDDEN)

        if GamePlayer.objects.filter(gameid=codes, character=char).exists():
            return Response({'error': 'Character already chosen. Please choose a different character.'}, status=status.HTTP_400_BAD_REQUEST)

        if player in lobby.players.all():
            return Response({'error': 'Player already in lobby'}, status=status.HTTP_400_BAD_REQUEST)

        lobby.players.add(player)
        if len(lobby.players.all()) == 6:
            lobby.status = "closed"

        lobby.save()
        newGamePlayer = GamePlayer(userid=player, gameid=lobby, character=char)
        newGamePlayer.save()

        return Response({'lobby': LobbySerializer(lobby).data}, status=status.HTTP_200_OK)

    except Lobby.DoesNotExist:
        return Response({'error': 'Invalid lobby code'}, status=status.HTTP_404_NOT_FOUND)
    except Player.DoesNotExist:
        return Response({'error': 'Invalid player'}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
def leave_lobby(request, id, codes):
    try:
        player = Player.objects.get(number=id)
        lobby = Lobby.objects.get(code=codes)
        gameplayer = GamePlayer.objects.get(userid = player, gameid = lobby)

        players_in_lobby = [l.name for l in lobby.players.all()]
        print("Players in the lobby:", players_in_lobby)

        if player not in lobby.players.all():
            return Response({'error': 'Player is not in the lobby'}, status=status.HTTP_400_BAD_REQUEST)

        lobby.players.remove(player)
        gameplayer.delete()
        
        if not lobby.players.all().exists():
            lobby.delete()
            
        lobby.save()
        
        
        return Response({'message': 'Left lobby'},
                        status=status.HTTP_200_OK)

    except Lobby.DoesNotExist:
        return Response({'error': 'Invalid lobby code'}, status=status.HTTP_404_NOT_FOUND)

    except Player.DoesNotExist:
        return Response({'error': 'Invalid player'}, status=status.HTTP_404_NOT_FOUND)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
def get_chosen_characters(request, codes):
  try:
    lobby = Lobby.objects.get(code=codes)
    game_players = GamePlayer.objects.filter(gameid=lobby)
    chosen_characters = [player.character for player in game_players]

    return Response({'characters': chosen_characters}, status=status.HTTP_200_OK)

  except Lobby.DoesNotExist:
    return Response({'error': 'Invalid lobby code'}, status=status.HTTP_404_NOT_FOUND)
  except Exception as e:
    return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
def start_game(request, codes):
    try:
        lobby = Lobby.objects.get(code=codes)
    except Lobby.DoesNotExist:
        return Response({'error': 'Lobby not found'}, status=status.HTTP_404_NOT_FOUND)

    # Check if lobby is already ongoing or finished
    if lobby.status != 'open':
        return Response({'error': 'Lobby is not open'}, status=status.HTTP_400_BAD_REQUEST)

    # Change lobby status to ongoing
    lobby.status = 'ongoing'
    lobby.save()

    # Get all players in the lobby
    players = lobby.players.all()

    # Choose 3 cards randomly from each category
    suspects = Cards.objects.filter(cardtype='s')
    weapons = Cards.objects.filter(cardtype='w')
    rooms = Cards.objects.filter(cardtype='r')

    chosen_cards = sample(list(suspects), 1) + sample(list(weapons), 1) + sample(list(rooms), 1)

    # Assign chosen cards to the lobby's answer
    lobby.answer.set(chosen_cards)

    # Get all remaining cards
    remaining_cards = list(Cards.objects.exclude(pk__in=[card.pk for card in chosen_cards]))

    # Shuffle remaining cards
    shuffled_cards = sample(remaining_cards, len(remaining_cards))

    # Distribute shuffled cards equally among players
    num_players = len(players)
    cards_per_player = len(shuffled_cards) // num_players

    for player in players:
        player_cards = shuffled_cards[:cards_per_player]
        shuffled_cards = shuffled_cards[cards_per_player:]
        for card in player_cards:
            game_player = GamePlayer.objects.get(userid=player, gameid=lobby)
            game_player.cards.add(card)

    return Response({"message": "Game started"}, status=status.HTTP_200_OK)


@api_view(['GET'])
def get_lobby_players_and_characters(request, codes):
    character_names = {
        '0': "Plum",
        '1': "Green",
        '2': "Mustard",
        '3': "Peacock",
        '4': "Scarlet",
        '5': "White",
    }

    try:
        lobby = Lobby.objects.get(code=codes)
        players_and_characters = [
            [player.name, character_names.get(game_player.character, "Unknown")]
            for player in lobby.players.all()
            for game_player in GamePlayer.objects.filter(gameid=lobby)
            if player == game_player.userid
        ]

        host_index = next((i for i, (player, _) in enumerate(players_and_characters) if player == lobby.host.name), None)
        if host_index is not None and host_index != 0:
            players_and_characters[0], players_and_characters[host_index] = players_and_characters[host_index], players_and_characters[0]

        return Response({'players': players_and_characters}, status=status.HTTP_200_OK)

    except Lobby.DoesNotExist:
        return Response({'error': 'Invalid lobby ID'}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
def check_game_status(request,codes):
    try:
        lobby = Lobby.objects.filter(status='ongoing',code=codes).first()
        if lobby:
            return Response({'game_status': 'started', 'lobby_code': lobby.code}, status=status.HTTP_200_OK)
        else:
            return Response({'game_status': 'not_started'}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
def populate_players_and_options(request,codes):
    # Fetch game players and lobby options from the database
    game_players = GamePlayer.objects.filter(gameid = codes).all()

    # Format game players and lobby options into the desired response format
    player_responses = [f"{player.userid.number}:{player.character}" for player in game_players]
   
    # Combine player and option responses
    server_response = player_responses

    return Response(server_response)


@api_view(['POST'])
def save_board_state(request):
    if request.method == 'POST':
        board_state = request.data.get('board_state')
        return Response({}, status=status.HTTP_200_OK)

@api_view(['GET'])
def get_board_state(request):
    if request.method == 'GET':
        lobby_code = request.GET.get('lobby_code')
        board_state = Lobby.objects.filter(code=lobby_code).values_list('board_state', flat=True).first()
        return Response({'board_state': board_state}, status=status.HTTP_200_OK)


@api_view(['POST'])
def change_turn(request, lobby_code):
    try:
        lobby = Lobby.objects.get(code=lobby_code)
    except Lobby.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
    
    players = lobby.players.all()
    
    current_turn_player = players.filter(number=lobby.turn).first()
    current_turn_index = list(players).index(current_turn_player)
    
    next_turn_index = (current_turn_index + 1) % len(players)
    next_turn_player = players[next_turn_index]
    
    lobby.turn = next_turn_player.number
    lobby.save()
    
    serializer = LobbySerializer(lobby)
    return Response(serializer.data)


@api_view(['GET'])
def check_user_turn(request, lobby_code, player_number):
    try:
        lobby = Lobby.objects.get(code=lobby_code)
    except Lobby.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
    
    if lobby.turn == player_number:
        return Response({'is_turn': True})
    else:
        return Response({'is_turn': False})
    
@api_view(['GET'])
def all_player_characters(request, lobby_code):
    try:
        lobby = Lobby.objects.get(code=lobby_code)
    except Lobby.DoesNotExist:
        return Response({"error": "Lobby not found"}, status=status.HTTP_404_NOT_FOUND)
    lobby_players = lobby.players.all()
    game_players = GamePlayer.objects.filter(userid__in=lobby_players, gameid=lobby)
    player_characters = [f"{player.number}:{game_player.character}" for player, game_player in zip(lobby_players, game_players)]

    return Response(player_characters)




@api_view(['GET'])
def get_player_card_stack(request, player_id):
    player = get_object_or_404(Player, number=player_id)
    game_players = GamePlayer.objects.filter(userid=player)
    if not game_players:
        return Response({'error': 'Player has no active games'}, status=status.HTTP_404_NOT_FOUND)
    
    card_stack = []
    for game_player in game_players:
        cards = game_player.cards.all()
        for card in cards:
            card_stack.append({
                'card_id': card.id,
                'card_name': card.card,
                'card_type': card.cardtype
            })
    
    return Response({'card_stack': card_stack}, status=status.HTTP_200_OK)


@api_view(['POST'])
def compare_cards(request,codes,suspect_card_id,weapon_card_id,room_card_id):

    suspect_card = get_object_or_404(Cards, pk=suspect_card_id)
    print(suspect_card.card)
    weapon_card = get_object_or_404(Cards, pk=weapon_card_id)
    room_card = get_object_or_404(Cards, pk=room_card_id)
    lobby = Lobby.objects.get(code=codes)

    answer_cards = lobby.answer.all()
    correct_suspect = any(card.card == suspect_card.card for card in answer_cards if card.cardtype == 's')
    correct_weapon = any(card.card == weapon_card.card for card in answer_cards if card.cardtype == 'w')
    correct_room = any(card.card == room_card.card for card in answer_cards if card.cardtype == 'r')
    
    if correct_suspect and correct_weapon and correct_room:
        lobby.status = "finished"
        return Response({'result': 'Correct guess! You win!'}, status=status.HTTP_200_OK)
    else:
        return Response({'result': 'Incorrect guess!'}, status=status.HTTP_400_BAD_REQUEST)
