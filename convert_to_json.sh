#!/usr/bin/env python3

import sys
import csv
import json

def main():
    if len(sys.argv) != 2:
        print("Usage: ./convert_to_json.sh input.csv")
        sys.exit(1)

    input_csv = sys.argv[1]
    groups = []
    current_group = None

    with open(input_csv, newline='', encoding='utf-8') as csvfile:
        reader = csv.reader(csvfile)
        next(reader)  # Skip header row
        for row in reader:
            # Skip empty rows
            if not any(row):
                continue

            # Check if it's a group line
            if row[0].strip() == '' and row[1].strip().startswith('Group'):
                # Extract group name and location
                group_info = row[1].strip().strip('"')
                if ' - ' in group_info:
                    name_part, location = group_info.split(' - ', 1)
                else:
                    name_part = group_info
                    location = ''
                group_name = name_part.strip()
                group_location = location.strip()
                # Create new group
                current_group = {
                    'name': group_name,
                    'location': group_location,
                    'members': []
                }
                groups.append(current_group)
            # Check if it's a member line
            elif row[0].strip() != '':
                # Extract member details
                name = row[1].strip()
                registration_number = row[2].strip()
                postcode = row[3].strip()
                member = {
                    'name': name,
                    'registrationNumber': registration_number,
                    'postcode': postcode
                }
                if current_group is not None:
                    current_group['members'].append(member)
                else:
                    # No current group; skip or handle error
                    pass
            else:
                # Other line; skip
                continue

    # Output JSON
    output_data = {
        'groups': groups
    }
    with open('glastonbury_groups.json', 'w', encoding='utf-8') as jsonfile:
        json.dump(output_data, jsonfile, indent=2)

if __name__ == '__main__':
    main()
