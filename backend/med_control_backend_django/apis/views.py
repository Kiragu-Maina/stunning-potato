from django.http import JsonResponse
from django.db.models import Avg
from django.views.decorators.csrf import csrf_exempt
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authtoken.models import Token

from rates.utils import utility
import json
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, viewsets
from rest_framework.permissions import AllowAny
from django.contrib.auth import authenticate, login
from django.contrib.auth.models import User
from .serializers import UserSerializer, ProductsSerializer, ProductSerializer, ShopSerializer, MedicationSerializer
from .models import Products, Product, Shop, Medication, Cart, CartItem
from .models import Cart, Order, OrderItem
from .serializers import OrderSerializer, CartItemSerializer
from django.shortcuts import get_object_or_404
from .serializers import CartItemSerializer 
from django_eventstream import send_event
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated

from .models import Profile

class UserInfoView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        user = request.user
        try:
            profile = user.profile  # Access the related Profile
            user_data = {
                'name': user.username,  # or user.get_full_name() if you use the full name
                'email': user.email,
                'about': profile.about,  # Correctly access 'about' from the user's profile
            }
            return Response(user_data)
        except Profile.DoesNotExist:
            # Handle case where user profile does not exist
            raise Http404("User profile not found")

class CartItemsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        user = request.user
        try:
            cart = Cart.objects.get(user=user)
            cart_items = CartItem.objects.filter(cart=cart)
            
            serializer = CartItemSerializer(cart_items, many=True)
            # from serializer.data get medication.itemName then append as name to response
            return Response(serializer.data)
        except Cart.DoesNotExist:
            return Response({"message": "No cart found for this user"}, status=404)
        
class CreateOrderView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        cart = Cart.objects.get(user=user)
        cart_items = cart.items.all()

        if not cart_items:
            return Response({'error': 'Your cart is empty'}, status=400)

        # Create an order
        order = Order.objects.create(user=user)
        total_cost = 0

        # Move items from cart to order
        for item in cart_items:
            OrderItem.objects.create(
                order=order,
                medication=item.medication,
                quantity=item.quantity,
                price=item.medication.price
            )
            total_cost += item.medication.price * item.quantity

        order.total_cost = total_cost
        order.save()

        # Clear the cart
        cart.items.all().delete()

        serializer = OrderSerializer(order)
        return Response(serializer.data, status=201)


class OrderStatementView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        orders = Order.objects.filter(user=request.user).order_by('-created_at')
        serializer = OrderSerializer(orders, many=True)
        return Response(serializer.data)
    
class AddToCartView(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user

        medication_id = request.data.get('medication_id')
        requested_quantity = int(request.data.get('quantity', 1))

        medication = get_object_or_404(Medication, pk=medication_id)

        # Check if requested quantity exceeds available stock
        if requested_quantity > medication.stock_quantity:
            return Response({"error": "Not enough stock available"}, status=status.HTTP_400_BAD_REQUEST)

        cart, created = Cart.objects.get_or_create(user=user)
        cart_item, created = CartItem.objects.get_or_create(
            cart=cart,
            medication=medication,
            defaults={'quantity': requested_quantity},
        )
        if not created:
            # Update the quantity if adding more of an existing item
            new_quantity = cart_item.quantity + requested_quantity
            # Check again for the total quantity against stock
            if new_quantity > medication.stock_quantity:
                return Response({"error": "Not enough stock available for the total requested quantity"}, status=status.HTTP_400_BAD_REQUEST)
            cart_item.quantity = new_quantity
            cart_item.save()

        
        medication.stock_quantity -= requested_quantity
        medication.save()

        return Response({"message": "Medication added to cart successfully"})

class MedicationViewSet(viewsets.ModelViewSet):
    queryset = Medication.objects.all()
    serializer_class = MedicationSerializer
    


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            username = serializer.validated_data['username']
            password = serializer.validated_data['password']
            email = serializer.validated_data['email']
            User.objects.create_user(username=username, email=email, password=password)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        user = authenticate(request, username=username, password=password)

        if user is not None:
            login(request, user)
            request.session['logged_in_user'] = username
            token, _ = Token.objects.get_or_create(user=user)

            # Include the token in the response data
            return Response({'token': token.key, 'message': 'Logged in successfully.'})
        
            
        return Response({'message': 'Invalid credentials.'}, status=status.HTTP_401_UNAUTHORIZED)




  