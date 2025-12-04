rules = []
updates = []
failures = []

with open('5_input.txt') as f:
    data = f.read()

def good(rule, update):
    a, b = rule.split('|')
    l = update.split(',')
    if a in update and b in update:
        if l.index(a) > l.index(b):
            return False
    return True


def swap(update, rule):
    a,b = rule.split('|')
    l = update.split(',')
    l.insert(l.index(a)+1, b)
    l.remove(b)
    s = ','.join(str(x) for x in l)
    return s


def fix(bad):
    for update in bad:
        for rule in rules:
            if not good(rule, update):
                new = swap(update,rule)
                bad[bad.index(update)] = new
                return bad
                break
    return bad


def get_sum_of_middles(updates):
    total = 0

    for update in updates:
        if update != '':
            l = update.split()
            for nums in l:
                vals = nums.split(',')
                mid = (len(vals) - 1)/2
                total += int(vals[int(mid)])
    return total


rules, _, updates = data.partition('\n\n')

rules = rules.split()
updates = updates.split()

for update in updates:
    for rule in rules:
        if not good(rule, update):
            if update in updates:
                failures.append(update)
                idx = updates.index(update)
                updates[idx] = ''

print('p1 total: ', get_sum_of_middles(updates))

while(1):
    updated = fix(failures.copy())
    if updated == failures:
        break
    else:
        failures = updated

print('p2 total: ', get_sum_of_middles(updated))