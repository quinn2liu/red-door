#  Red Door Inventory Manager

### Major Features

1. `InventoryView`

    Baseline Features:

    - make `InventoryItemView` look better.

    Possible Improvements:

    - filer items

    Optimizations:

    - load only a certain number of items from the collection

    Questions:


2. `ItemView`

    Baseline Features:

    - Generate QR codes (from: UUID)

        - Make QR codes shareable/printable

    Improvements:

    - Create different views/add item views for different types of items (art has different fields than a couch)

    - This is a monster file that you should break apart into smaller views.

    Optimizations:

    -  Add Image Compression for image upload

    - Add some form of version tracking (only update model data if there are changes)

    Questions:



3. `PullListView`

    Baseline Features:

    1. Create PullListModel

    2. 

    Possible Improvements:


    Optimizations:


    Questions:

    - how do you envision pull lists will be created? on my end, I see 2 ways this could work. 1: In the warehouse, the user hits "create pull list" and everytime they want to add an item to the pull list, they hit a "scan item" button, scan said item, and then it's added to the pull list. 2: When users say they want to create a pull list, they go into the app and pick out 4 of chair x, 2 of table y, and 3 of lamp z to go into the list. both should be possible but while I'm trying to get a working product as fast as possible I want to prioritize the most-used features.
    
 

4. `InstalledListView`

5. Authentication

- add it

- update security rules on the database and storage


