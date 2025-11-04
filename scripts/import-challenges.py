#!/usr/bin/env python3
"""
Import BSidesSF 2019 CTF challenges into CTFd platform
Usage: python import-challenges.py --url http://localhost:8000 --token YOUR_ADMIN_TOKEN
"""

import argparse
import requests
import yaml
import sys
from pathlib import Path

class CTFdImporter:
    def __init__(self, url, token):
        self.url = url.rstrip('/')
        self.token = token
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Token {token}',
            'Content-Type': 'application/json'
        })

    def create_challenge(self, challenge_data):
        """Create a challenge in CTFd"""

        # Map challenge type to connection info
        if challenge_data['type'] == 'web':
            connection = f"URL: http://YOUR_SERVER:{challenge_data.get('deployment', {}).get('service_port', 8000)}"
            if 'path' in challenge_data:
                connection = f"URL: http://YOUR_SERVER{challenge_data['path']}"
        elif challenge_data['type'] == 'network':
            port = challenge_data.get('port', challenge_data.get('deployment', {}).get('service_port', 5000))
            connection = f"nc YOUR_SERVER {port}"
        elif challenge_data['type'] == 'file':
            files = challenge_data.get('files', [])
            if files:
                filename = Path(files[0]).name
                connection = f"Download: http://YOUR_SERVER:8080/{filename}"
            else:
                connection = "Files available on file server"
        else:
            connection = "See challenge description"

        # Build challenge description
        description = challenge_data['description'] + f"\n\n**Connection Info:**\n```\n{connection}\n```"

        # Prepare challenge payload
        payload = {
            'name': challenge_data['name'],
            'category': challenge_data['category'],
            'description': description,
            'value': challenge_data['points'],
            'state': 'visible',
            'type': 'standard'
        }

        # Create challenge
        try:
            response = self.session.post(f'{self.url}/api/v1/challenges', json=payload)
            response.raise_for_status()
            challenge_id = response.json()['data']['id']
            print(f"✓ Created challenge: {challenge_data['name']} (ID: {challenge_id})")

            # Add flag
            flag_payload = {
                'challenge_id': challenge_id,
                'content': challenge_data['flag'],
                'type': 'static'
            }
            flag_response = self.session.post(f'{self.url}/api/v1/flags', json=flag_payload)
            flag_response.raise_for_status()
            print(f"  ✓ Added flag for {challenge_data['name']}")

            return challenge_id

        except requests.exceptions.RequestException as e:
            print(f"✗ Failed to create challenge {challenge_data['name']}: {e}")
            if hasattr(e.response, 'text'):
                print(f"  Error details: {e.response.text}")
            return None

    def import_from_yaml(self, yaml_file):
        """Import all challenges from YAML file"""
        with open(yaml_file, 'r') as f:
            data = yaml.safe_load(f)

        challenges = data.get('challenges', [])
        print(f"\nImporting {len(challenges)} challenges from {yaml_file}")
        print("=" * 60)

        stats = {
            'success': 0,
            'failed': 0,
            'categories': {}
        }

        for challenge in challenges:
            category = challenge['category']
            if category not in stats['categories']:
                stats['categories'][category] = 0

            if self.create_challenge(challenge):
                stats['success'] += 1
                stats['categories'][category] += 1
            else:
                stats['failed'] += 1

        # Print summary
        print("\n" + "=" * 60)
        print(f"Import Summary:")
        print(f"  Total: {len(challenges)}")
        print(f"  Success: {stats['success']}")
        print(f"  Failed: {stats['failed']}")
        print(f"\nChallenges by category:")
        for category, count in sorted(stats['categories'].items()):
            print(f"  {category}: {count}")

def main():
    parser = argparse.ArgumentParser(description='Import CTF challenges into CTFd')
    parser.add_argument('--url', required=True, help='CTFd URL (e.g., http://localhost:8000)')
    parser.add_argument('--token', required=True, help='CTFd admin API token')
    parser.add_argument('--yaml', default='challenges.yaml', help='Path to challenges YAML file')

    args = parser.parse_args()

    # Check if YAML file exists
    if not Path(args.yaml).exists():
        print(f"Error: YAML file not found: {args.yaml}")
        sys.exit(1)

    # Test connection
    try:
        response = requests.get(f"{args.url}/api/v1/challenges")
        print(f"✓ Connected to CTFd at {args.url}")
    except requests.exceptions.RequestException as e:
        print(f"✗ Failed to connect to CTFd: {e}")
        sys.exit(1)

    # Import challenges
    importer = CTFdImporter(args.url, args.token)
    importer.import_from_yaml(args.yaml)

if __name__ == '__main__':
    main()
