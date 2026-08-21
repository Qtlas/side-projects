import matplotlib.pyplot as plt
from utils import *

def nb_cve_per_year(data : dict):
    f = {k : len(data[k]) for k in data}

    plt.figure()
    plt.plot(f.keys(), f.values(), marker='o')
    plt.xlabel("Year")
    plt.ylabel("Number of CVE")
    plt.title("Number of  per Year")
    plt.grid(True)
    plt.show()



def cwe_repartition(data : dict, top_n  : int = 10):
    f = {}
    for year in data:
        for cve in data[str(year)]:
            for cwe in data[str(year)][cve]["CWE"]:
                if cwe in f:
                    f[cwe] += 1
                else:
                    f[cwe] = 1
 
    sorted_items = sorted(f.items(), key=lambda x: x[1], reverse=True)

    labels = []
    sizes = []
    others = 0

    for i, (cwe, count) in enumerate(sorted_items):
        if i < top_n:
            labels.append(cwe)
            sizes.append(count)
        else:
            others += count

    if others > 0:
        labels.append("OTHER")
        sizes.append(others)

    plt.figure()
    plt.pie(sizes, labels=labels, autopct='%1.1f%%', startangle=100)
    plt.title(f"CWE repartition")
    plt.axis('equal')
    plt.show()


def cvss_score_distrib(data: dict):
    scores = []
    for year in data:
        for cve in data[str(year)]:
            score = data[str(year)][cve].get("SCORE")
            if score and score != '':
                scores.append(float(score))
    
    plt.figure(figsize=(12, 6))
    plt.hist(scores, bins=20, edgecolor='black', alpha=0.7)
    plt.xlabel("CVSS Score")
    plt.ylabel("Nuber of CVE")
    plt.title("Score CVSS distribution")
    plt.grid(True, alpha=0.3)
    

    plt.axvline(x=4.0, color='yellow', linestyle='--', label='Medium (4.0)')
    plt.axvline(x=7.0, color='orange', linestyle='--', label='High (7.0)')
    plt.axvline(x=9.0, color='red', linestyle='--', label='Critical (9.0)')
    plt.legend()
    plt.tight_layout()
    plt.show()


def month_distrib(data: dict):
    months = {i: 0 for i in range(1, 13)}
    month_names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    
    dates = [data[year][cve].get("DATE") for year in data for cve in data[year] 
             if data[year][cve].get("DATE")]
    
    for date_str in dates:
        month = int(date_str.split('-')[1])
        months[month] += 1
    
    plt.figure(figsize=(12, 6))
    plt.bar(month_names, [months[i] for i in range(1, 13)], color='skyblue', edgecolor='black')
    plt.xlabel("Month")
    plt.ylabel("Number of CVE")
    plt.title("Distribution des CVE dans l'annees")
    plt.grid(True, alpha=0.3, axis='y')
    plt.tight_layout()
    plt.show()


def produit_most_vuln(data: dict, top_n: int = 10):
    produit_count = {}  
    top_produit = []
    for year in data:
        for cve in data[year]:
            if data[year][cve]['PRODUIT'] != '':
                if data[year][cve]['PRODUIT'] in produit_count:
                    produit_count[data[year][cve]['PRODUIT']] += 1
                else:
                    produit_count[data[year][cve]['PRODUIT']] = 1

                if len(top_produit) < top_n:
                    if data[year][cve]['PRODUIT'] not in top_produit:  
                        top_produit.append(data[year][cve]['PRODUIT'])
                elif data[year][cve]['PRODUIT'] not in top_produit:
                    for i in range(len(top_produit)):
                        if produit_count[data[year][cve]['PRODUIT']] > produit_count[top_produit[i]]:
                            top_produit.remove(top_produit[i])
                            top_produit.append(data[year][cve]['PRODUIT'])
                            

    top_produit.sort(key=lambda p: produit_count[p], reverse=True)
    counts = [produit_count[p] for p in top_produit]

    plt.figure(figsize=(12, top_n))
    plt.barh(top_produit, counts, color='steelblue', edgecolor='black')
    plt.xlabel("Number of CVE", fontweight='bold')
    plt.ylabel("Vendor", fontweight='bold')
    plt.title(f"Top {top_n} most vulnerable Pproduit", fontweight='bold')
    plt.gca().invert_yaxis()
    plt.grid(True, alpha=0.3, axis='x')
    plt.tight_layout()
    plt.show()


def moyenne_score_par_cwe(data: dict, cwe_cible: str) -> float:
    scores = []
    for year, cves in data.items():
        for cve_id, cve_data in cves.items():
            if cwe_cible is not None:
                if cwe_cible in cve_data.get("CWE", []):
                    score = cve_data.get("SCORE")
            else:
                score = cve_data.get("SCORE")
            if score is not None:
                try:
                    scores.append(float(score))
                except:
                    continue
    return sum(scores) / len(scores)


def correlation_score_complexity(data: dict) -> dict:
    
    correlations = {
        "AV": {"N": [], "A": [], "L": [], "P": []},
        "AC": {"L": [], "H": []},
        "PR": {"N": [], "L": [], "H": []},
        "UI": {"N": [], "R": []}
    }
    
    for year, cves in data.items():
        for cve_id, cve_data in cves.items():
            try:
                score = float(cve_data.get("SCORE", 0))
            except (ValueError, TypeError):
                continue
                
            metric = cve_data.get("METRIC", "")
            if not metric:
                continue
            
            parts = metric.split("/")
            for part in parts:
                if ":" not in part:
                    continue
                key, value = part.split(":")
                if key in correlations and value in correlations[key]:
                    correlations[key][value].append(score)
    
    stats = {}
    for metric_type, values in correlations.items():
        stats[metric_type] = {}
        for value, scores in values.items():
            if scores:
                stats[metric_type][value] = {
                    "moyenne": sum(scores) / len(scores),
                    "min": min(scores),
                    "max": max(scores),
                    "count": len(scores)
                }
    
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    fig.suptitle('Correlation score CVSS and metrics complexite', fontsize=16, fontweight='bold')
    
    metric_names = {
        "AV": "Attack Vector",
        "AC": "Attack Complexity",
        "PR": "Privileges Required",
        "UI": "User Interaction"
    }
    
    color_palette = ['#440154', '#31688e', '#35b779', '#fde724']
    
    for idx, (metric_type, metric_stats) in enumerate(stats.items()):
        ax = axes[idx // 2, idx % 2]
        
        if not metric_stats:
            continue
        
        categories = list(metric_stats.keys())
        moyennes = [metric_stats[cat]["moyenne"] for cat in categories]
        counts = [metric_stats[cat]["count"] for cat in categories]
        
        colors = [color_palette[i % len(color_palette)] for i in range(len(categories))]
        bars = ax.bar(categories, moyennes, color=colors, alpha=0.8, edgecolor='black')
        
        for bar, count in zip(bars, counts):
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2., height,
                   f'{height:.2f}\n(n={count})',
                   ha='center', va='bottom', fontsize=9)
        
        ax.set_ylabel('Score Moyen', fontsize=11, fontweight='bold')
        ax.set_title(metric_names[metric_type], fontsize=12, fontweight='bold')
        ax.set_ylim(0, 10)
        ax.grid(axis='y', alpha=0.3, linestyle='--')
        ax.axhline(y=7, color='red', linestyle='--', alpha=0.5, label='High Severity')
        ax.axhline(y=4, color='orange', linestyle='--', alpha=0.5, label='Medium Severity')
        
        if idx == 0:
            ax.legend(fontsize=8)
    
    plt.tight_layout()
    plt.show()
    




def generer_heatmap_score_cwe_cvss(data: dict) -> dict:
    
    heatmap_data = {
        "cwe_par_score": {},
        "cwe_par_attack_vector": {},
        "score_par_attack_complexity": {},
        "matrice_complete": []
    }
    
    for year, cves in data.items():
        for cve_id, cve_data in cves.items():
            if not isinstance(cve_data, dict):
                continue
            
            try:
                score = float(cve_data.get("SCORE", 0))
            except (ValueError, TypeError):
                score = 0
                
            cwe_list = cve_data.get("CWE", [])
            metric = cve_data.get("METRIC", "")
            
            av, ac = "Unknown", "Unknown"
            if metric:
                parts = metric.split("/")
                for part in parts:
                    if part.startswith("AV:"):
                        av = part.split(":")[1]
                    elif part.startswith("AC:"):
                        ac = part.split(":")[1]
            
            score_range = get_score_range(score)
            
            for cwe in cwe_list:
                if cwe not in heatmap_data["cwe_par_score"]:
                    heatmap_data["cwe_par_score"][cwe] = {}
                heatmap_data["cwe_par_score"][cwe][score_range] = \
                    heatmap_data["cwe_par_score"][cwe].get(score_range, 0) + 1
                
                if cwe not in heatmap_data["cwe_par_attack_vector"]:
                    heatmap_data["cwe_par_attack_vector"][cwe] = {}
                heatmap_data["cwe_par_attack_vector"][cwe][av] = \
                    heatmap_data["cwe_par_attack_vector"][cwe].get(av, 0) + 1
                
                heatmap_data["matrice_complete"].append({
                    "CWE": cwe,
                    "Score_Range": score_range,
                    "Score": score,
                    "AV": av,
                    "AC": ac
                })
            
            if score_range not in heatmap_data["score_par_attack_complexity"]:
                heatmap_data["score_par_attack_complexity"][score_range] = {}
            heatmap_data["score_par_attack_complexity"][score_range][ac] = \
                heatmap_data["score_par_attack_complexity"][score_range].get(ac, 0) + 1
    
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))
    fig.suptitle('Heatmap Score/CWE/CVSS', fontsize=16, fontweight='bold')
    
    top_cwes = sorted(heatmap_data["cwe_par_score"].items(), 
                     key=lambda x: sum(x[1].values()), reverse=True)[:15]
    
    score_ranges = ["None", "Low", "Medium", "High", "Critical"]
    cwe_names = [cwe for cwe, _ in top_cwes]
    
    matrix1 = []
    for cwe in cwe_names:
        row = [heatmap_data["cwe_par_score"][cwe].get(sr, 0) for sr in score_ranges]
        matrix1.append(row)
    
    im1 = axes[0].imshow(matrix1, cmap='YlOrRd', aspect='auto')
    axes[0].set_xticks(range(len(score_ranges)))
    axes[0].set_xticklabels(score_ranges, rotation=45)
    axes[0].set_yticks(range(len(cwe_names)))
    axes[0].set_yticklabels(cwe_names, fontsize=8)
    axes[0].set_title('Top 15 CWE par Score Range')
    axes[0].set_xlabel('Score Range')
    axes[0].set_ylabel('CWE')
    
    for i in range(len(cwe_names)):
        for j in range(len(score_ranges)):
            text = axes[0].text(j, i, matrix1[i][j],
                              ha="center", va="center", color="black", fontsize=8)
    
    plt.colorbar(im1, ax=axes[0])
    
    av_values = ["N", "A", "L", "P"]
    matrix2 = []
    for cwe in cwe_names:
        row = [heatmap_data["cwe_par_attack_vector"][cwe].get(av, 0) for av in av_values]
        matrix2.append(row)
    
    im2 = axes[1].imshow(matrix2, cmap='viridis', aspect='auto')
    axes[1].set_xticks(range(len(av_values)))
    axes[1].set_xticklabels(av_values)
    axes[1].set_yticks(range(len(cwe_names)))
    axes[1].set_yticklabels(cwe_names, fontsize=8)
    axes[1].set_title('Top 15 CWE per Attack vector')
    axes[1].set_xlabel('Attack Vector')
    axes[1].set_ylabel('CWE')
    
    for i in range(len(cwe_names)):
        for j in range(len(av_values)):
            text = axes[1].text(j, i, matrix2[i][j],
                              ha="center", va="center", color="white", fontsize=8)
    
    plt.colorbar(im2, ax=axes[1])
    plt.tight_layout()
    plt.show()
    