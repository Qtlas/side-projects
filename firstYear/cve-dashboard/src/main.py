from traitements import *
from utils import *

CHOICE_DICT = {
    "1": [nb_cve_per_year, "Number of CVE per year"],
    "2": [cwe_repartition, "CWE repartition"],
    "3": [cvss_score_distrib, "Score distribution"],
    "4": [month_distrib, "Monthly repartition"],
    "5": [produit_most_vuln, "Most vulnerable product"],
    "7": [moyenne_score_par_cwe, "Average score for a CWE"],
    "8": [moyenne_score_par_cwe, "Average score for in total"],
    "9": [correlation_score_complexity, "Corelation between score and metrics"],
    "10": [ generer_heatmap_score_cwe_cvss, "Heatmap of "]
}

def print_header():
    print("\n" + "="*60)
    print(" "*15 + "CVE DASHBOARD")
    print("="*60)

def print_menu():
    print("\n[AVAILABLE TREITMENTS]")
    print("-" * 60)
    for k, v in CHOICE_DICT.items():
        print(f"  {k}. {v[1]}")
    print("-" * 60)
    print("  0. Change search criteria")
    print("  Q. Quit")

def get_search_criteria():
    print("\n[SEARCH KEYWORD]")
    print("-" * 60)
    print("  • Type 'all' for all CVEs")
    print("  • Type expression (ex : 'CWE = CWE-89 & SCORE > 7 || DATE == 2024-01-01'")
    print("-" * 60)
    return input("Search by: ").strip()

if __name__ == "__main__":
    data = None
    
    while True:
        print("\033c")
        print_header()
        
        if data is None:
            search = get_search_criteria()
            if search.lower() == 'q':
                break
            
            if search.lower() == "all":
                data = load_json_by_range_year(None)
            else:
                logicTab = expression_to_tab(search)
                data = load_json_by_range_year(logicTab)
            
            if data is None:
                print("\n[ERROR] Failed to load data")
                input("Press Enter to continue...")
                continue
        
        print_menu()
        
        choice = input("\nSelect treatment: ").strip().upper()
        
        if choice == 'Q':
            print("\nBye Bye!")
            break
        elif choice == '0':
            data = None
            continue
        elif choice in CHOICE_DICT:
            print("\n" + "="*60)
            print(f" {CHOICE_DICT[choice][1].upper()}")
            print("="*60)
            
            if choice == '7':
                cwe = input("\nEnter CWE (e.g., CWE-89): ").strip()
                result = CHOICE_DICT[choice][0](data, cwe)
                print(f"\nAverage score for {cwe}: {result:.2f}")
            elif choice == '8':
                result = CHOICE_DICT[choice][0](data, None)
                print(f"\nAverage score in total: {result:.2f}")
            else:
                CHOICE_DICT[choice][0](data)
            
            input("\nPress Enter to continue...")
        else:
            print("\n[ERROR] Invalid choice")
            input("Press Enter to continue...")