# Tests simples des fonctions du projet 

from utils import *

print("=== TEST DES FONCTIONS ===\n")

# -------------------------
# Données de test minimales
# -------------------------
data_test = {
    "2024": {
        "CVE-TEST-1": {
            "CVE": "CVE-TEST-1",
            "CWE": ["CWE-89"],
            "DATE": "2024-06-10 10:30:00",
            "SCORE": 8.2,
            "METRIC": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N",
            "TITLE": "SQL Injection",
            "DESC": "Test SQL injection",
            "PRODUIT": "TestApp"
        },
        "CVE-TEST-2": {
            "CVE": "CVE-TEST-2",
            "CWE": ["CWE-79"],
            "DATE": "2024-02-01 08:00:00",
            "SCORE": 4.5,
            "METRIC": "CVSS:3.1/AV:L/AC:H/PR:L/UI:R",
            "TITLE": "XSS",
            "DESC": "Test XSS",
            "PRODUIT": "TestApp"
        }
    }
}

# -------------------------
# Test expression_to_tab
# -------------------------
print(">> Test expression_to_tab")
expr = 'SCORE > 7 && CWE == "CWE-89"'
logic_tab = expression_to_tab(expr)
print("Expression :", expr)
print("Résultat   :", logic_tab, "\n")

# -------------------------
# Test is_valid_cve_by_logic_tab
# -------------------------
print(">> Test is_valid_cve_by_logic_tab")
cve = data_test["2024"]["CVE-TEST-1"]
result = is_valid_cve_by_logic_tab(cve, logic_tab)
print("CVE testée :", cve["CVE"])
print("Valide ?   :", result, "\n")

# -------------------------
# Test get_score_range
# -------------------------
print(">> Test get_score_range")
for s in [0, 3.5, 6.8, 8.9, 9.8]:
    print(f"Score {s} → {get_score_range(s)}")
print()

# -------------------------
# Test moyenne_score_par_cwe
# -------------------------
print(">> Test moyenne_score_par_cwe")
moy = moyenne_score_par_cwe(data_test, "CWE-89")
print("Moyenne score CWE-89 :", moy, "\n")

# -------------------------
# Test correlation_score_complexity
# -------------------------
print(">> Test correlation_score_complexity")
stats_corr = correlation_score_complexity(data_test)
print("Résultat statistique :")
for metric, values in stats_corr.items():
    print(metric, "→", values)
print()

# -------------------------
# Test generer_heatmap_score_cwe_cvss
# -------------------------
print(">> Test generer_heatmap_score_cwe_cvss")
heatmap_data = generer_heatmap_score_cwe_cvss(data_test)
print("Clés générées :", heatmap_data.keys())
print("Exemple CWE par score :", heatmap_data["cwe_par_score"], "\n")

print("=== FIN DES TESTS ===")
