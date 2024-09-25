import os
import secrets
from flask import Flask, jsonify, request, session, send_from_directory
from PySQLiteDBConnection import Connect
from dotenv import load_dotenv, set_key as dset_key
from cryptography.fernet import Fernet
from flask_mail import Mail, Message
from flask_cors import CORS

app = Flask("Work Solution API")
CORS(app)

load_dotenv()

app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['SECRET_KEY'] = secrets.token_hex(64)
app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USE_SSL'] = False
app.config['MAIL_USERNAME'] = 'uworksolution@gmail.com'
app.config['MAIL_PASSWORD'] = 'onji izse aazu qrkm'
app.config['MAIL_DEFAULT_SENDER'] = ('Work Solution', 'noreply@worksolution.com')

ekey = os.getenv("ENCRYPTION_KEY")

if ekey is None:
    ekey = Fernet.generate_key().decode()
    dotenv_path = ".env"
    dset_key(dotenv_path, "ENCRYPTION_KEY", ekey)

app.config['KEY'] = ekey.encode()

mail = Mail(app)
connection = Connect('data\\database.sqlite3')

EXTENSIONS = {
    'pdf': 'pdf',
    'doc': 'docs',
    'docx': 'docs',
    'jpg': 'image',
    'jpeg': 'image',
    'png': 'image',
    'webp': 'image',
    'pptx': 'powerpoint',
    'txt': 'text',
    'xls': 'calcs',
    'xlsx': 'calcs',
    'zip': 'compress',
    'rar': 'compress',
    'tar': 'compress',
    '7z': 'compress',
}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in EXTENSIONS.keys()

def get_files():
    files = []
    for filename in os.listdir(app.config['UPLOAD_FOLDER']):
        if filename == '.keep':
            continue
        files.append({
            'name': filename,
            'type': filename.split('.')[-1],
            'icon': get_file_icon(filename)
        })
    return files

def rename_duplicates(name):
    names = [file["name"] for file in get_files()]
    if name not in names:
        return name
    name_parts = name.rsplit('.', 1)
    name_parts[0] += " (duplicado)"
    new_name = '.'.join(name_parts)
    return rename_duplicates(new_name)

def get_file_icon(filename):
    extension = filename.split('.')[-1]
    return f"{EXTENSIONS.get(extension, 'file.png')}.webp"

def encrypt(key):
    cipher_suite = Fernet(app.config['KEY'])
    return cipher_suite.encrypt(key.encode('utf-8'))

def decrypt(encrypted_key):
    cipher_suite = Fernet(app.config['KEY'])
    return cipher_suite.decrypt(encrypted_key).decode('utf-8')

@app.route('/api/files', methods=['GET'])
def api_get_files():
    files = get_files()
    return jsonify({'status': 'success', 'files': files}), 200

@app.route('/api/register', methods=['POST'])
def api_register():
    data = request.get_json()
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    repassword = data.get('repassword')

    if not all([name, email, password, repassword]):
        return jsonify({'status': 'error', 'message': 'Todos los campos son obligatorios'}), 400

    if password != repassword:
        return jsonify({'status': 'error', 'message': 'Las contraseñas no coinciden'}), 400

    connection.connect()
    if connection.read_table_with_condition('users', {'email': email}):
        connection.close()
        return jsonify({'status': 'error', 'message': 'Usuario ya existente'}), 400

    encrypted_password = encrypt(password)
    connection.insert_into_table('users', {
        'name': name,
        'email': email,
        'password': encrypted_password
    })
    connection.close()
    return jsonify({'status': 'success', 'message': 'Registro exitoso'}), 201

@app.route('/api/login', methods=['POST'])
def api_login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not all([username, password]):
        return jsonify({'status': 'error', 'message': 'Todos los campos son obligatorios'}), 400

    connection.connect()
    user = connection.read_table_with_condition('users', {'email': username})
    connection.close()

    if user and password == decrypt(user[0][3]):
        session['email'] = user[0][2]
        session['id'] = user[0][0]
        session['name'] = user[0][1]
        return jsonify({'status': 'success', 'message': 'Inicio de sesión exitoso', 'user': session['name']}), 200

    return jsonify({'status': 'error', 'message': 'Credenciales inválidas'}), 401

@app.route('/api/logout', methods=['POST'])
def api_logout():
    session.clear()
    return jsonify({'status': 'success', 'message': 'Sesión cerrada exitosamente'}), 200

@app.route('/api/upload', methods=['POST'])
def api_upload():
    if 'file' not in request.files:
        return jsonify({'status': 'error', 'message': 'No se encontró el archivo'}), 400

    file = request.files['file']
    name = request.form.get('name')

    if file.filename == '':
        return jsonify({'status': 'error', 'message': 'No se seleccionó ningún archivo'}), 400

    if not allowed_file(file.filename):
        return jsonify({'status': 'error', 'message': 'Tipo de archivo no permitido'}), 400

    if name:
        name += "." + file.filename.split('.')[-1]
    else:
        name = file.filename

    filepath = os.path.join(
        app.config['UPLOAD_FOLDER'], rename_duplicates(name))
    file.save(filepath)
    return jsonify({'status': 'success', 'message': 'Archivo subido exitosamente', 'filename': name}), 200

@app.route('/api/password-recovery', methods=['POST'])
def api_password_recovery():
    data = request.get_json()
    email = data.get('email')

    if not email:
        return jsonify({'status': 'error', 'message': 'El correo electrónico es obligatorio'}), 400

    connection.connect()
    user = connection.read_table_with_condition('users', {'email': email})
    connection.close()

    if user:
        password_plain = decrypt(user[0][3])
        html_body = f"""
            <html lang="es">
            <body style="font-family: Arial, sans-serif; color: #333;">
                <div style="max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f4f4f9; border-radius: 8px; border: 1px solid #e5e5e5;">
                    <div style="text-align: center;">
                        <!-- Logo de Work Solution -->
                        <img src="https://lh3.googleusercontent.com/fife/ALs6j_F_OsQvW_8CHA3DcZGKgZeZioBYbwnvYWHfdX8wr1W4Mr4hHMYrl0qN0N-OOMki-JMEK3hdLvbqtZVuOOFTZidssVN4WApGHHfEXO255F4ZntWx021FhDq1JE2EGHg2zKwv_a5MALClOkUXxw_g8TYB61UKZoM5ix4O7zzUGvZpXK_jc1lddw-Xw5XbTRD0iSrOdAw44Sh1i0tbRcRNXGgnLt6rMfRqDfUHSFhAEUH6QjKCEFuxsJTSORiBOUHLbVeA9vo-Zvx_kihylhiVpzvJewcBWa8BUBTs7YOIU2jaRMBmgjSEWUl3pj_meVExKVnWZf2ZI5_IoyisHAQPYu1CSQ-x8BVQ_8s74wQhY6WRT_IwfLGHTwbxV-nGtXYUvY0x-mjkk0mxwWb9d9g3mqJc0SwX4Ts_GhsjyaSA774lWgMQ0vxT3hu8XSWdaHiK4K08K4DnuPQrNGk5TMlKwHC2rjFSyaJOWFAAHtS9_fQcECrcjoJmUPyREQCuDP90uNo3rvJ7e3GsIlVaNCAwNc0ZMOsLgSFAeMktV2eXYZlckGmvA7Yx8v3_WoeAo4rdsYtXZxYmwluqdewkMqUva9NlW-Eax_X56ee7DL93LqmtZQWWVp94k-RhsLX4m6O0V6n2UZDNjTE3ehKItU3G8oaYoffGPWHVGrQHH38vt1bATdMdj1aSMqZFiCKxp1vrQju311N1kSduXFNfSGPWa_56u2--4E1ZvMIO32_tqUDSIyKX4gXqvM7DuOBVCKLjW4MbBbFehKFEaB93TohH7feNORmiLBJP-D2NARZTK5AdYwyNYZD8qNSsqaNj4-aymDXnx55aVkRNcffCL9sZDaNIQPWbHPd6_xQR0OUHiNnLVN8T_Q7NvMUmwrLIklpPq_wCBQ-fWPL4Gh_7Z-QlGlmuonrmkR71UIFd1HHWO264qI6_tuGvtsTooc7NfGZHP88I94VSseUjy1Mo4AMQI4a4ZwK24AmOvGLyAALDFXZ8piwbvBNjU5Bp1zlfoiysiEVcIAok43EhZ1NE2yJptFPu0xManX-q7zijSWLVm07sq77HET6qI-pj7ovHs_xt9Pz7wdUASdVicKSQdOWd4Wm03Iv5pRXipz-9Vok4H_bDtVp079i9IiKpEVNzvqRVjsAgHjtwt9FOi4m2-TfXxYFO0Eqa9ZMKfOuUTPDAN9tFyJuT1e567oLQoM2IZ83wDaQG5OIWnUqopgN7Xh31xWnehL8LvRdLIK8h_y_q-NBZwWDWsogin-gDwvLemMiaEu-x9cFKhzSYfpsSh-p7L5lydtZdnjd48epFpcr6TgpypM2W_mJ1DZQQVdWVKPFYKIQjFLYSY9R7ijuImvxe2qmFIwVhPvFHbZ2LTDQdIFmfsRebImweL0frU4yaxUTbcAMXKGxbjG-DysndDAvG3ziphJA_qWC8T3RBSc_PsHlQee-SX-5SnggC68Gjpab3XHTklQRudW4TUKU3O7jT4rtbnqLACX5wz5LeY0osvBubxecL-KaegGa9oxyK_etejVz53b3tkeMD0gxWeyywraSgZrLTyeQR0FZIKIBpPelc5-FYD1B0yv63enGVy2EsQRIXiy22ta-5wm_nD2p1U67PziDXMigYHjQ5_xj72HGcLLVd5WUHVVuAmTZ0nV-GNp2E-1scwKPYlGth8HJtFPTD5AFd4YqZw0J0pqmVWTU0lSYxqp5-WQqL8bvIhtq8PeZRXfeJ07nW-EocqE_VLGQzMs9TLyA5wh6x=w1920-h991" alt="Work Solution" width="100">
                        <h2 style="color: #007bff;">Work Solution</h2>
                    </div>
                    <p>Estimado <strong>{user[0][1]}</strong>,</p>
                    <p>Has solicitado la recuperación de tu contraseña. Si no has sido tú, por favor ignora este correo.</p>
                    <p>Tu contraseña es: <strong>{password_plain}</strong></p>
                    <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>
                    <p>Saludos,<br>El equipo de <strong>Work Solution</strong></p>
                </div>
            </body>
            </html>
            """
        msg = Message('Recuperación de contraseña', recipients=[email])
        msg.html = html_body
        mail.send(msg)
        return jsonify({'status': 'success', 'message': 'Correo enviado'}), 200
    else:
        return jsonify({'status': 'error', 'message': 'Correo no registrado'}), 404

@app.route('/api/download/<filename>', methods=['GET'])
def api_download_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

if __name__ == '__main__':
    app.run(debug=True)
