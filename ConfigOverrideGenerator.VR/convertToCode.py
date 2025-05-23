import ast
from collections import defaultdict

# Load the input file
with open("output.txt", "r") as file:
    lines = file.readlines()

# Store structured overrides
overrides = defaultdict(lambda: {"parent": "", "nested": defaultdict(dict)})

for line in lines:
    line = line.strip()
    if not line:
        continue
    parsed = ast.literal_eval(line.replace('""', '"'))

    class_name, parent_class, modifications = parsed

    overrides[class_name]["parent"] = parent_class

    for path, attr, value in modifications:
        path_key = tuple(path[0])  # flatten outermost bracket
        overrides[class_name]["nested"][path_key][attr] = value

# Generate output
with open("code.txt", "w") as output:
    for class_name, data in overrides.items():
        output.write(f"class {class_name} : {data['parent']}\n{{\n")
        output.write("\t//empty\n")
        for path, attributes in data["nested"].items():
            indent = "\t"
            output.write(f"{indent}class {' : '.join(path)}\n{indent}{{\n")
            for attr, val in attributes.items():
                output.write(f"{indent}\t{attr} = {val};\n")
            output.write(f"{indent}}};\n")
        output.write("};\n")

print("code.txt generated successfully.")
