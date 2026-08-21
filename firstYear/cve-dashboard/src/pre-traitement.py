import os
import json
from utils import *

SEARCH_DICT = {
    "CVE": ["cve"], 
    "CWE": ["nvd,weaknesses"], 
    "DATE": ["nvd,created"], 
    "SCORE": ["nvd,metrics,cvssV3_1,score", "nvd,metrics,cvssV2_0,score"],  
    "METRIC": ["nvd,metrics,cvssV3_1,vector", "nvd,metrics,cvssV2_0,vector"], 
    "TITLE": ["advisories,title", "mitre,title"], 
    "DESC": ["nvd,description"], 
    "PRODUIT": ["nvd,vendors"]
}


def get_by_str_path(obj_dict: dict, path_list: list):
    for str_path in path_list:
        path = str_path.split(',')
        try:
            val = obj_dict[path[0]]
            for key in path[1:]:
                val = val[key]
            
            if val or val == 0: 
                return val
        except:
            continue
    
    return "" 


def search_by(obj_dict: dict, key: str):
    if key not in SEARCH_DICT: 
        return -1
    return get_by_str_path(obj_dict, SEARCH_DICT[key])


for dirName in os.listdir("../opencve-kb/"):
    new_path = f"db/{dirName}"
    if not os.path.exists(new_path):
        os.makedirs(new_path)
    
    for cveName in os.listdir(f"../opencve-kb/{dirName}"): 
        filePath = f"../opencve-kb/{dirName}/" + cveName
        data = json_to_dict(filePath)
        
        with open(new_path + "/" + cveName, 'w') as f:
            new_data = {k: search_by(data, k) for k in SEARCH_DICT}
            
            if new_data["DATE"]:
                new_data["DATE"] = new_data["DATE"].split('.')[0].replace('T', ' ').replace('+00:00', '')
            if len(new_data["PRODUIT"]) > 0:
                new_data["PRODUIT"] = new_data["PRODUIT"][0]
            
            f.write(json.dumps(new_data))