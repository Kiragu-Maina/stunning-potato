from rest_framework import serializers
from django.contrib.auth.models import User

from .models import Medication

from .models import CartItem, OrderItem, Order

class OrderItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderItem
        fields = ['medication', 'quantity', 'price']

class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)

    class Meta:
        model = Order
        fields = ['id', 'created_at', 'status', 'total_cost', 'items']

class CartItemSerializer(serializers.ModelSerializer):
    name = serializers.SerializerMethodField()
    price = serializers.SerializerMethodField()
    class Meta:
        model = CartItem
        fields = ['id', 'medication', 'quantity', 'name', 'price']

    
    def get_name(self, obj):
        # Ensure that medication is related to obj and has a name attribute
        return obj.medication.name if obj.medication else "No Name"

    def get_price(self, obj):
        # Ensure that medication is related to obj and has a price attribute
        return obj.medication.price if obj.medication else 0.0

class MedicationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Medication
        fields = '__all__' 

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('username', 'email', 'password')
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password']
        )
        return user
