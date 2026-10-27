import sys
import glob
import yaml


def extract_arch_packages(pkg_dir):
    packages = set()
    for filepath in sorted(glob.glob(f"{pkg_dir}/*.yml")):
        with open(filepath, "r") as f:
            try:
                data = yaml.safe_load(f)
                if not isinstance(data, dict):
                    continue
                for _entry, distros in data.items():
                    if isinstance(distros, dict) and 'arch' in distros:
                        arch_val = distros['arch']
                        if arch_val:
                            packages.update(str(arch_val).split())
            except yaml.YAMLError as e:
                print(f"Error reading {filepath}: {e}", file=sys.stderr)
    return list(packages)

    if __name__ == "__main__":
        target_dir = sys.argv[1] if len(sys.argv) > 1 else "."
        pkgs = extract_arch_packages(target_dir)
        print(" ".join(pkgs))
