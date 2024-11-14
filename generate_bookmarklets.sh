#!/bin/bash

# Check if the JSON file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_json_file>"
  exit 1
fi

# Read the JSON file path
json_file=$1

# Begin HTML output
cat <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bookmarklets for Groups</title>
    <script>
        function updateBookmarklet(groupIndex) {
            const leadBookerIndex = document.getElementById('leadBooker_' + groupIndex).value;
            const groupData = JSON.parse(document.getElementById('groupData_' + groupIndex).textContent);

            // Move the selected lead booker to the start
            const leadBooker = groupData.members.splice(leadBookerIndex, 1)[0];
            groupData.members.unshift(leadBooker);

            // Generate the bookmarklet code
            const bookmarkletCode = groupData.members.map((member, index) =>
                "document.getElementById('registrations_" + index + "__RegistrationId').value='" + member.registrationNumber + "';" +
                "document.getElementById('registrations_" + index + "__PostCode').value='" + member.postcode + "';"
            ).join('');

            // Update the bookmarklet link
            document.getElementById('bookmarkletLink_' + groupIndex).href = "javascript:(function()%7B" + encodeURIComponent(bookmarkletCode) + "%7D)()";
        }
    </script>
</head>
<body>
    <h1>Group Bookmarklets</h1>
    <ul>
EOF

# Parse each group in JSON
jq -c '.groups[]' "$json_file" | while IFS= read -r group; do
    groupName=$(echo "$group" | jq -r '.name')
    groupLocation=$(echo "$group" | jq -r '.location')
    members=$(echo "$group" | jq -c '.members')
    groupIndex=$((groupIndex + 1))

    # Extract member names for dropdown
    memberOptions=$(echo "$members" | jq -r '.[] | "\(.name)"')

    # Generate HTML for each group with dropdown for lead booker
    cat <<EOF
        <li>
            <strong>$groupName</strong> - Location: $groupLocation
            <br>
            <label for="leadBooker_$groupIndex">Select Lead Booker:</label>
            <select id="leadBooker_$groupIndex" onchange="updateBookmarklet($groupIndex)">
EOF

    # Generate options for the dropdown
    echo "$members" | jq -r '. | to_entries[] | "<option value=\"" + (.key | tostring) + "\">" + .value.name + "</option>"'

    # Closing HTML for the dropdown and bookmarklet link
    cat <<EOF
            </select>
            <br>
            Bookmarklet: <a id="bookmarkletLink_$groupIndex" href="#">$groupName</a>
            <script type="application/json" id="groupData_$groupIndex">
                $group
            </script>
        </li>
EOF

done

# End HTML output
cat <<EOF
    </ul>
</body>
</html>
EOF
