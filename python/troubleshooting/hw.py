print('hello world')
# n = int(input('Enter integer to check if it is even: '))

try:
    n = int(input('Enter integer to check if it is even: '))
except ValueError:
    print(f'Run program again with valid integer')
    exit()

if n%2 == 0:
    print(f'{n} is even')
else:
    print(f'{n} is ood')
    # SyntaxError: expected ':'