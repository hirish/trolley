import json
from copy import copy

bbc = 'bbc_crawl.json'

def multi_parse():
    data = []
    data += bbc_parse(bbc)
    return data

def bbc_parse(site):
    data = basic_parse(site)
    for line in data:
        line['ingredients'] = bbc_ingredients(copy(line['ingredients']))
        line['rating'] = line['rating'].count('<span class=\"on\">')
    return data

def bbc_ingredients(s):
    start_i = s.index('itemprop="ingredients') + 23
    ingredients = {}
    i = 1
    while start_i != 23:
        try:
            s = s[start_i:]
            end_i = s.index('</li>')
            ingredients[str(i)] = {}
            ingredients[str(i)]['name'] = s[:end_i]
            _type, quantity = bbc_measurements(ingredients[str(i)]['name'])
            start_i = s.index('itemprop="ingredients') + 23
            i += 1
        except ValueError:
            start_i = 23
    return ingredients

def bbc_measurements(s):
    _type, quantity = bbc_spoon_measurements(s)
    if not _type:
        _type, quantity = bbc_normal_measurements(s)
    if _type:
        return _type, quantity
    else:
        return 'count', 1

def bbc_normal_measurements(s):
    nums = [int(x) for x in s.split() if x.isdigit()]
    unit = None
    _type = None
    quantity = None
    for num in nums:
        s_num = str(num)
        unit_start = s.index(s_num) + len(s_num)
        if unit_start < len(s) - 2 and s[unit_start] != ' ':
            if ' ' in s[unit_start:]:
                unit_end = s[unit_start:].index(' ')
                unit = s[unit_start:unit_end].lower()
                quantity = num
            else:
                unit = s[unit_start:].lower()
                quantity = num
            break
    if unit:
        if 'ml' in unit:
            _type = 'volume'
        elif 'l' in unit:
            _type = 'volume'
        elif 'g' in unit:
            _type = 'weight'
        elif 'kg' in unit:
            _type = 'weight'
        else:
            _type = 'count'
    elif len(nums) > 0:
        quantity = nums[0]
        _type = 'count'
    return _type, quantity

def bbc_spoon_measurements(s):
    _type = None
    quantity = None
    if 'tsp' in s:
        _type = 'volume'
        quantity = get_quantity('tsp', s) * 5 # 1 tsp is 5ml
    elif 'tbsp' in s:
        _type = 'volume'
        quantity = get_quantity('tbsp', s) * 15 # 1 tbsp is 15ml
    else:
        _type = None
        quantity = None
    return _type, quantity

def get_quantity(unit, s):
    s = s.lower()
    i = s.index(unit)
    quantity = [int(x) for x in s[:i].split() if x.isdigit()]
    if len(quantity) == 0:
        quantity = 1
    else:
        quantity = quantity[-1]  
    return quantity


print "bbc_spoon_measurements('4 tbsp of milk')", bbc_spoon_measurements('4 tbsp of milk')
print "bbc_spoon_measurements('4 tsp of milk')", bbc_spoon_measurements('4 tsp of milk')
print "bbc_spoon_measurements('400ml of milk')", bbc_spoon_measurements('400ml of milk')


def basic_parse(site):
    json_data=open(site)
    data = []
    for line in json_data:
        j_line = json.loads(line)
        try:
            # if the page was scraped properly we should have 11 fields
            if len(j_line['results'][0]) == 11:
                url = j_line['pageUrl']
                j_line = j_line['results'][0]
                j_line['url'] = url
                data.append(j_line)
        except KeyError:
            continue
    return data



