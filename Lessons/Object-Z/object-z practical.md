```
    Building:
        Approved: (True, False)
        <!-- date of registration should not be less than 1.1.999 -->
        date_of_registration:
            pre: > 1.1.1000 and < tomorrow
        area: float
        ownerShip: Owner
        Coordinate: LIST(coordinate)

    Owner:
        name:
            <!-- name should not be empty -->
            pre: name.length > 3
        dob: DATE
        address: 
            pre: address.length > 0
        
    Land_segments:
        type: (apartment, house, farm, ....)
        owner: (Owner)
        coordinate: LIST(coordinate)
        area: float
        buildings: LIST(Buildings)

    Coordinate:
        latitude: float
        longtitude: float

    


```