#get list of computers
$servers = get-content .\servers.txt

foreach ($s in $servers){
.\PsExec.exe \\$s -accepteula -nobanner -s powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1 -UseBasicParsing | iex"
}