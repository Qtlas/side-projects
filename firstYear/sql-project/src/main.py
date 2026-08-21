import json
import os
import tkinter as tk
from tkinter import ttk, messagebox
import psycopg2
import psycopg2.extras

# Folder where this script lives, so requetes.json is found
# no matter where the script is run from
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))


# Paramètres connexion base de données
DB = {
    "host": "localhost",
    "port": 5432,
    "dbname": "football",
    "user": "postgres",
    "password": ""
}

# Couleurs interface
BG = "#F8FAFC"
SIDEBAR = "#0F172A"
GREEN = "#16A34A"


class App(tk.Tk):

    def __init__(self):
        super().__init__()

        self.title("⚽ Football Explorer")
        self.geometry("1300x760")
        self.configure(bg=BG)

        # Connexion PostgreSQL
        self.conn = psycopg2.connect(**DB)

        # Charge les requêtes SQL du fichier json
        with open(os.path.join(SCRIPT_DIR, "requetes.json"), encoding="utf8") as f:
            self.queries = json.load(f)

        self.current_query = None
        self.inputs = {}

        # Création interface graphique
        self.create_ui()

    def create_ui(self):

        # Menu gauche
        sidebar = tk.Frame(self, bg=SIDEBAR, width=260)
        sidebar.pack(side="left", fill="y")

        # Zone principale
        content = tk.Frame(self, bg=BG)
        content.pack(fill="both", expand=True)

        tk.Label(
            sidebar,
            text="REQUÊTES",
            fg="white",
            bg=SIDEBAR,
            font=("Arial", 14, "bold")
        ).pack(pady=12)

        # Liste des catégories + requêtes
        self.tree = ttk.Treeview(sidebar)
        self.tree.pack(fill="both", expand=True, padx=10, pady=10)

        for category, data in self.queries.items():
            parent = self.tree.insert("", "end", text=category)

            for query_name in data:
                self.tree.insert(parent, "end", text=query_name)

        self.tree.bind("<<TreeviewSelect>>", self.select_query)

        self.title_label = tk.Label(content, bg=BG, font=("Arial", 18, "bold"))
        self.title_label.pack(anchor="w", padx=20, pady=(20, 5))

        self.desc_label = tk.Label(content, bg=BG, fg="gray")
        self.desc_label.pack(anchor="w", padx=20)

        tk.Label(content, text="SQL", bg=BG).pack(anchor="w", padx=20)

        # Affiche la requête SQL
        self.sql_box = tk.Text(content, height=7,
                               bg="#111827", fg="#7DD3FC")
        self.sql_box.pack(fill="x", padx=20)

        tk.Label(content, text="Paramètres", bg=BG).pack(
            anchor="w",
            padx=20,
            pady=(15, 0)
        )

        # Zone des paramètres de la requête
        self.param_frame = tk.Frame(content, bg=BG)
        self.param_frame.pack(fill="x", padx=20)

        # Bouton exécuter
        tk.Button(
            content,
            text="▶ Exécuter",
            command=self.run_query,
            bg=GREEN,
            fg="white",
            relief="flat"
        ).pack(anchor="w", padx=20, pady=20)

        self.result_count = tk.Label(content, bg=BG)
        self.result_count.pack(anchor="w", padx=20)

        # Tableau résultats SQL
        self.table = ttk.Treeview(content, show="headings")
        self.table.pack(fill="both", expand=True, padx=20, pady=15)

    def select_query(self, event):

        # Récupère la requête choisie
        item = self.tree.selection()[0]
        parent = self.tree.parent(item)

        if not parent:
            return

        category = self.tree.item(parent)["text"]
        query_name = self.tree.item(item)["text"]

        query = self.queries[category][query_name]
        self.current_query = query

        # Affiche infos de la requête
        self.title_label.config(text=query_name)
        self.desc_label.config(text=query["description"])

        self.sql_box.delete("1.0", "end")
        self.sql_box.insert("1.0", query["sql"])

        # Supprime anciens paramètres
        for widget in self.param_frame.winfo_children():
            widget.destroy()

        self.inputs.clear()

        # Crée les champs paramètres automatiquement
        for param in query["params"]:

            tk.Label(
                self.param_frame,
                text=param["nom"],
                bg=BG
            ).pack(side="left")

            entry = tk.Entry(self.param_frame, width=12)
            entry.insert(0, param["defaut"])
            entry.pack(side="left", padx=8)

            self.inputs[param["nom"]] = entry

    def run_query(self):

        if not self.current_query:
            return

        # Récupère valeurs saisies
        params = {
            name: entry.get()
            for name, entry in self.inputs.items()
        }

        try:
            # Exécute la requête SQL
            cursor = self.conn.cursor(
                cursor_factory=psycopg2.extras.DictCursor
            )

            cursor.execute(
                self.current_query["sql"],
                params
            )

            rows = cursor.fetchall()
            columns = [d[0] for d in cursor.description]

            # Vide ancien tableau
            self.table.delete(*self.table.get_children())
            self.table["columns"] = columns

            # Crée colonnes résultat
            for col in columns:
                self.table.heading(col, text=col)
                self.table.column(col, width=150)

            # Ajoute résultats dans tableau
            for row in rows:
                self.table.insert("", "end", values=list(row))

            self.result_count.config(
                text=f"{len(rows)} résultat(s)"
            )

        # Affiche erreur SQL si problème
        except Exception as err:
            messagebox.showerror("Erreur SQL", str(err))


# Lance le programme
if __name__ == "__main__":
    App().mainloop()