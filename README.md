# SafeTrade

## Setup Instructions

1. Clone the repository
2. Add the credentials file based on your environment:
   - Path: `assets/credentials.json`
3. Create a `.env` file in the root directory with the following values based on your environment (prod/dev):
   ```
   USER_SPREADSHEET_ID=your_user_spreadsheet_id
   STOCK_LIST_SPREADSHEET_ID=your_stock_list_spreadsheet_id 
   STOCK_FORM_SPREADSHEET_ID=your_stock_form_spreadsheet_id
   IMAGE_FOLDER_ID=your_image_folder_id
   ```
4. Open terminal in the project directory
5. Run the following commands in order:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```