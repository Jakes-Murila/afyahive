from pathlib import Path
from xml.sax.saxutils import escape
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, Table,
                                TableStyle, PageBreak, KeepTogether, Preformatted)

ROOT = Path(r'C:\Users\G\Desktop\afyahive\frontend_hive')
OUT = Path(r'C:\Users\G\Desktop\afyahive\output\pdf\afyahive_frontend_hive_code_guide.pdf')
OUT.parent.mkdir(parents=True, exist_ok=True)

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name='TitleAfya', parent=styles['Title'], fontName='Helvetica-Bold', fontSize=25, leading=30, textColor=colors.HexColor('#173A5E'), alignment=TA_CENTER, spaceAfter=16))
styles.add(ParagraphStyle(name='H1Afya', parent=styles['Heading1'], fontName='Helvetica-Bold', fontSize=17, leading=22, textColor=colors.HexColor('#173A5E'), spaceBefore=12, spaceAfter=8))
styles.add(ParagraphStyle(name='H2Afya', parent=styles['Heading2'], fontName='Helvetica-Bold', fontSize=12, leading=16, textColor=colors.HexColor('#C87C06'), spaceBefore=9, spaceAfter=5))
styles.add(ParagraphStyle(name='BodyAfya', parent=styles['BodyText'], fontName='Helvetica', fontSize=8.8, leading=12, spaceAfter=6))
styles.add(ParagraphStyle(name='TinyAfya', parent=styles['BodyText'], fontName='Helvetica', fontSize=7.1, leading=9))
styles.add(ParagraphStyle(name='CellHead', parent=styles['BodyText'], fontName='Helvetica-Bold', fontSize=8, leading=10, textColor=colors.white))
code_style = ParagraphStyle('CodeCell', fontName='Courier', fontSize=6.4, leading=8, textColor=colors.HexColor('#17212B'))
source_style = ParagraphStyle('Source', fontName='Courier', fontSize=5.1, leading=6.3, textColor=colors.HexColor('#17212B'))

def p(text, style='BodyAfya'):
    return Paragraph(escape(text).replace('\n', '<br/>'), styles[style])

def code(text, style=code_style):
    return Paragraph(escape(text).replace(' ', '&nbsp;').replace('\n', '<br/>'), style)

def table(rows, widths=(8.1*cm, 9.0*cm)):
    t = Table([[p('Code / file responsibility', 'CellHead'), p('Explanation and logic', 'CellHead')]] + rows, colWidths=widths, repeatRows=1, hAlign='LEFT')
    t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#173A5E')),
        ('GRID', (0,0), (-1,-1), .25, colors.HexColor('#CAD4E0')),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('BACKGROUND', (0,1), (-1,-1), colors.HexColor('#F8FAFC')),
        ('LEFTPADDING', (0,0), (-1,-1), 6), ('RIGHTPADDING', (0,0), (-1,-1), 6),
        ('TOPPADDING', (0,0), (-1,-1), 6), ('BOTTOMPADDING', (0,0), (-1,-1), 6),
    ]))
    return t

guidance = {
'lib/main.dart': ('Application entry point', 'Initializes Flutter bindings before plugins such as secure storage are used, then mounts the root AfyaHiveApp widget.'),
'lib/app/afya_hive_app.dart': ('Application composition root', 'Defines MaterialApp once: product title, system light/dark theme selection, disabled debug banner, and AuthGate as the initial route decision.'),
'lib/core/network/api_config.dart': ('API host selection', 'Centralizes the backend address. A compile-time API_BASE_URL takes priority. Web uses localhost; Android emulator uses 10.0.2.2 to reach the host computer; desktop uses 127.0.0.1.'),
'lib/core/network/api_exception.dart': ('Typed network failure', 'Stores a human-readable message and optional HTTP status. UI code can catch this type and show a safe message without exposing transport details.'),
'lib/core/network/api_client.dart': ('Authenticated HTTP client', 'Adds JSON and bearer-token headers, enforces a 20-second timeout, validates both status and the backend success field, returns only data, and turns malformed/network failures into ApiException.'),
'lib/core/theme/app_colors.dart': ('Brand colour tokens', 'Named constants prevent repeated hexadecimal literals and keep health-state colours, surfaces, and brand colours consistent.'),
'lib/core/theme/app_theme.dart': ('Global Material theme', 'Builds light and dark ThemeData from the brand seed. It standardizes form fields, buttons, navigation, cards, app bars, and snackbars so feature screens do not restyle every control.'),
'lib/core/ui/app_card.dart': ('Reusable tappable card', 'Applies one card visual style. When onTap is supplied it wraps the card in Material and InkWell, providing ripple/keyboard semantics while non-interactive cards remain lightweight.'),
'lib/core/ui/primary_button.dart': ('Primary action button', 'Uses a full-width FilledButton and accepts null onPressed for Flutter’s disabled state. Screens use this to prevent duplicate submissions during loading.'),
'lib/core/ui/section_header.dart': ('Section heading primitive', 'Renders a title with an optional trailing action. Expanded gives the title remaining width while the action stays aligned.'),
'lib/features/auth/data/auth_session_store.dart': ('Secure local token storage', 'Stores only the access token with flutter_secure_storage rather than ordinary preferences. The key is namespaced to the product.'),
'lib/features/auth/data/auth_repository.dart': ('Authentication repository', 'Owns unauthenticated login/register requests and converts the JSON response into typed AuthSession and AuthUser models. Login and register share transport/error rules.'),
'lib/features/auth/presentation/auth_gate.dart': ('Authentication gate', 'Reads the stored token once and shows a progress state until complete. It then selects LoginScreen or AppShell before protected UI is displayed.'),
'lib/features/auth/presentation/login_screen.dart': ('Sign-in presentation', 'Owns form controllers, validators, password visibility, remember-me state, loading lock, API call, token saving, error snackbar, and replacement navigation to the protected shell.'),
'lib/features/auth/presentation/register_screen.dart': ('Account registration presentation', 'Validates names, email, password/confirmation; disables repeat submission; registers through AuthRepository; persists the returned token; and replaces the route with AppShell.'),
'lib/features/shell/presentation/app_shell.dart': ('Authenticated navigation shell', 'Keeps tab index state and displays the selected feature screen with persistent navigation. Logout clears the secure token after confirmation and returns to login.'),
'lib/features/home/presentation/home_screen.dart': ('Home dashboard', 'Loads dashboard content via ApiClient, shows loading/error/retry UI, and routes feature cards to their existing modules. It remains a presentation layer rather than duplicating API logic.'),
'lib/features/vitals/presentation/vitals_screen.dart': ('Vitals feature', 'Loads readings for a selected range, finds the latest record per vital type, opens a preselected entry sheet from each card, validates numeric input, posts manual readings, refreshes after saving, and derives visual status from the Vital model.'),
'lib/features/settings/presentation/profile_screen.dart': ('Profile editing feature', 'Loads profile data into disposable controllers, validates required fields, PATCHes the profile, prevents duplicate saves, and supplies loading/error feedback.'),
'lib/features/settings/presentation/settings_screen.dart': ('Settings feature', 'Provides profile navigation, support/privacy actions, and logout confirmation. It does not store business data itself.'),
'lib/features/common/presentation/resource_list_screen.dart': ('Generic CRUD screen', 'A configurable feature screen for list/create/delete API resources. ResourceField describes each form control, InputKind selects input behavior, and the screen handles load, validation, submit lock, confirmation, refresh, and error states.'),
'lib/features/common/presentation/service_catalog.dart': ('Service catalogue metadata', 'Maps AfyaHive healthcare modules to title, icon, backend route, empty-state text, and fields. Keeping this metadata separate avoids copy-pasting similar service screens.'),
'test/widget_test.dart': ('Widget smoke test', 'Pumps LoginScreen and asserts expected visible content. This is a fast guard that the application UI can be constructed in a test environment.'),
'pubspec.yaml': ('Project manifest', 'Defines package name, SDK limits, dependencies, asset directories, and Flutter configuration. It is the source of truth for build tooling and packages.'),
'analysis_options.yaml': ('Static-analysis policy', 'Includes Flutter’s recommended lint rules so the analyzer can flag correctness, style, and maintainability concerns.'),
}

folder_rows = [
('lib/app/', 'Application composition. Named app because it contains the root widget and app-wide wiring, rather than a domain feature.'),
('lib/core/', 'Cross-cutting building blocks: network, theme, and UI primitives. Named core because feature modules depend on it, but it does not depend on features except the authenticated client’s session store.'),
('lib/features/', 'Business-facing modules grouped by capability: auth, home, vitals, settings, shell, and common.'),
('features/*/data/', 'Data-access classes and models. The name separates HTTP/storage concerns from widgets.'),
('features/*/presentation/', 'Screens and widgets. The name makes UI responsibility explicit and keeps it separate from data handling.'),
('assets/images/', 'Bundled visual brand assets referenced by Image.asset.'),
('android/, ios/, linux/, macos/, windows/, web/', 'Flutter platform runners and native build configuration. These folders are required for their targets; Runner is native host code, not disposable application cache.'),
('test/', 'Automated tests, isolated from production source.'),
]

platform_rows = [
('android/', 'Gradle/Kotlin launcher and Android manifest; configures Android packaging, permissions, app label, and Flutter entry activity.'),
('ios/ and macos/', 'Xcode projects, Swift app delegates, asset catalogues, launch screens, entitlement and build configuration. Runner is the Apple-side application host.'),
('windows/ and linux/', 'CMake desktop runner code. It creates the native window, registers Flutter plugins, and embeds the Flutter engine.'),
('web/', 'HTML bootstrap, web manifest, favicon, and PWA icons used by browser builds.'),
('assets/images/', 'The AfyaHive logo and healthcare banner. Binary image assets are described rather than reproduced as source code.'),
]

def footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(colors.HexColor('#E8A515'))
    canvas.line(1.5*cm, 1.25*cm, A4[0]-1.5*cm, 1.25*cm)
    canvas.setFont('Helvetica', 7)
    canvas.setFillColor(colors.HexColor('#546273'))
    canvas.drawString(1.5*cm, .85*cm, 'AfyaHive Frontend Hive - code reference')
    canvas.drawRightString(A4[0]-1.5*cm, .85*cm, f'Page {doc.page}')
    canvas.restoreState()

story = []
story += [Spacer(1, 2.5*cm), p('AfyaHive Frontend Hive', 'TitleAfya'), p('Complete code and architecture guide', 'H1Afya'), p('This reference documents the maintained Flutter source in frontend_hive. Each implementation file is paired with an explanation of why it exists, how it is named, and how its logic works. Generated platform files and binary images are catalogued by purpose instead of copied verbatim.', 'BodyAfya'), Spacer(1, .8*cm), p('Scope: frontend_hive only | Generated on 20 August 2026', 'BodyAfya'), PageBreak()]
story += [p('1. Folder architecture and naming', 'H1Afya'), p('The project follows a feature-first Flutter structure. Code is grouped by the user capability it serves, while universal concerns live in core.', 'BodyAfya')]
story.append(table([[p(a, 'BodyAfya'), p(b, 'BodyAfya')] for a,b in folder_rows]))
story += [Spacer(1, .3*cm), p('Reading the naming conventions', 'H2Afya'), p('snake_case is used for Dart filenames because it is the Dart convention. Widget classes use PascalCase. A leading underscore (for example _AddVital) means the class or member is library-private: it is deliberately reusable only inside that file. presentation identifies UI code; data identifies communication/storage code; common holds generic modules intentionally shared by more than one healthcare feature.', 'BodyAfya'), PageBreak()]

story += [p('2. Runtime flow', 'H1Afya'), p('Launch -> main.dart -> AfyaHiveApp -> AuthGate -> LoginScreen or AppShell. Authenticated feature screens call ApiClient -> PHP API -> JSON. Success returns data; failure becomes ApiException -> feature screen message/retry UI.', 'BodyAfya')]
story.append(table([
    [code('main() -> runApp(AfyaHiveApp)'), p('Bootstraps Flutter and installs the root widget.')],
    [code('AfyaHiveApp -> MaterialApp(home: AuthGate)'), p('Applies the global theme and delegates the first navigation decision to authentication.')],
    [code('AuthGate -> secure token -> LoginScreen | AppShell'), p('Prevents protected views being selected before local session state is known.')],
    [code('Screen -> ApiClient -> api.php?route=...'), p('Feature UI asks one shared client to send the token and decode the backend’s response contract.')],
    [code('{ success, message, data }'), p('The backend response shape lets all screens distinguish an accepted request from an error consistently.')],
]))
story.append(PageBreak())

story += [p('3. Source-by-source code reference', 'H1Afya'), p('The left column identifies the file and representative logic; the right column explains its behavior. The complete text of every maintained Dart source file is included in the appendix.', 'BodyAfya')]
for path in sorted(guidance):
    if not (ROOT/path).exists():
        continue
    src = (ROOT/path).read_text(encoding='utf-8')
    lines = src.splitlines()
    preview = '\n'.join(lines[:min(len(lines), 16)])
    left = p(path, 'H2Afya')
    leftwrap = [left, code(preview + ('\n...' if len(lines)>16 else ''))]
    story.append(KeepTogether([Table([[leftwrap, p(guidance[path][1], 'BodyAfya')]], colWidths=(8.1*cm,9.0*cm), style=TableStyle([('VALIGN',(0,0),(-1,-1),'TOP'),('GRID',(0,0),(-1,-1),.25,colors.HexColor('#CAD4E0')),('BACKGROUND',(0,0),(-1,-1),colors.HexColor('#F8FAFC')),('LEFTPADDING',(0,0),(-1,-1),6),('RIGHTPADDING',(0,0),(-1,-1),6),('TOPPADDING',(0,0),(-1,-1),6),('BOTTOMPADDING',(0,0),(-1,-1),6)])), Spacer(1, 7)]))
story.append(PageBreak())

story += [p('4. Vitals status logic', 'H1Afya'), p('The Vital model in vitals_screen.dart is the single place that converts a stored numeric reading into a display value, a user-facing status, and a status colour. These are general screening thresholds, not a diagnosis.', 'BodyAfya')]
story.append(table([
    [code("blood_pressure\nvalue >= 180 || diastolic >= 120 || value < 90\n-> Abnormal"), p('Blood pressure uses the systolic value as value and the lower number as secondary. Extreme high values or systolic under 90 get the abnormal label.')],
    [code("blood_pressure\nvalue >= 130 || diastolic >= 80\n-> Above healthy range\notherwise -> Within healthy range"), p('Readings not extreme but at or over these thresholds are highlighted for awareness. Remaining readings receive the healthy-range label.')],
    [code("heart_rate\nvalue < 60 || value > 100\n-> Abnormal\notherwise -> Normal"), p('The current application treats 60-100 bpm as normal for a resting general screening range.')],
    [code("blood_oxygen\n< 90 Abnormal; < 95 Above healthy range;\n>= 95 Normal"), p('SpO2 has a middle caution band. The display unit is percent.')],
    [code("temperature\n< 35 or >= 38 Abnormal;\n>= 37.5 Above healthy range;\notherwise Normal"), p('The display unit is Celsius. The status colour is danger for abnormal, primary-dark for caution, and success for normal/recorded.')],
    [code("weight -> Recorded"), p('Weight is stored and displayed but is intentionally not classified as normal or abnormal because a safe range requires individual context such as height, age, pregnancy status, and clinical guidance.')],
]))
story.append(PageBreak())

story += [p('5. Native/platform project files', 'H1Afya'), p('Flutter generates much of this support code. These files are still required to build for their platforms, so they are documented by role rather than expanded as generic boilerplate.', 'BodyAfya')]
story.append(table([[p(a, 'BodyAfya'), p(b, 'BodyAfya')] for a,b in platform_rows]))
story += [p('Important: Do not delete a Runner folder if you intend to build that platform. The Runner project is the platform host. Build artefacts such as build/ and platform flutter/ephemeral/ output can be regenerated.', 'BodyAfya'), PageBreak()]

story += [p('Appendix A. Complete maintained Dart source', 'H1Afya'), p('This appendix reproduces the handwritten application source under lib/ and the widget test. It intentionally excludes generated plugin registrants and platform boilerplate; their role is documented above.', 'BodyAfya')]
dart_paths = sorted([x for x in ROOT.glob('lib/**/*.dart') if x.is_file()]) + [ROOT/'test/widget_test.dart']
for file in dart_paths:
    rel = file.relative_to(ROOT).as_posix()
    story += [p(rel, 'H2Afya'), Preformatted(file.read_text(encoding='utf-8'), source_style), Spacer(1, 8)]

doc = SimpleDocTemplate(str(OUT), pagesize=A4, rightMargin=1.5*cm, leftMargin=1.5*cm, topMargin=1.45*cm, bottomMargin=1.65*cm, title='AfyaHive Frontend Hive Code Guide', author='AfyaHive')
doc.build(story, onFirstPage=footer, onLaterPages=footer)
print(OUT)
