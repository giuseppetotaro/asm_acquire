from flask import Flask, jsonify, request
import subprocess

app = Flask(__name__)

cmd = "./service.sh"

def command(verb):
    out = subprocess.run(f"{cmd} {verb}", shell=True, check=True, capture_output=True)
    out = out.stdout.decode('utf-8')
    return {'message': f'{out}.'}, 200

@app.route('/start', methods=['POST'])
def start_process():
    data = request.get_json()
    if 'identifier' not in data:  # identifier is not used yet!
        return jsonify({'message': 'Indentifier not provided.'}), 400
    response, status_code = command('start')
    return jsonify(response), status_code

@app.route('/stop', methods=['GET'])
def stop_process():
    response, status_code = command('stop')
    return jsonify(response), status_code

@app.route('/status', methods=['GET'])
def get_status():
    response, status_code = command('status')
    return jsonify(response), status_code

if __name__ == '__main__':
    app.run(debug=True)
