

## Setting up the project

1. Clone the repository
2. Create a virtual environment:
    ```sh
    python3 -m venv venv
    ```

3. Activate the virtual environment:
    - On macOS and Linux:
        ```sh
        source venv/bin/activate
        ```
    - On Windows:
        ```sh
        .\venv\Scripts\activate
        ```

4. Install dependencies:
    ```sh
    pip install -r requirements.txt
    ```
5. Run the SQL mesh UI:
    ```sh
    sqlmesh ui
    ```
   navigate to `http://127.0.0.1:8000/` in your browser to view the UI.
6. Or run the SQL mesh CLI:
    ```sh
    sqlmesh plan
    ```
