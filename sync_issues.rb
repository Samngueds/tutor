require 'octokit'

# Recebe os tokens e nomes dos repositórios do ambiente
public_repo_token = ENV['PUBLIC_REPO_TOKEN']
private_repo_token = ENV['PRIVATE_REPO_TOKEN']
public_repo = ENV['PUBLIC_REPO']
private_repo = ENV['PRIVATE_REPO']

# Configura os clientes Octokit para os repositórios
public_client = Octokit::Client.new(access_token: public_repo_token)
private_client = Octokit::Client.new(access_token: private_repo_token)

def fetch_issues(client, repo)
  puts "Buscando issues do repositório #{repo}..."
  issues = client.issues(repo, state: 'all').map do |issue|
    { number: issue.number, title: issue.title, body: issue.body }
  end
  puts "Issues encontradas: #{issues.size}"
  issues
rescue => e
  puts "Erro ao buscar issues: #{e.message}"
  []
end

def create_issue(client, repo, title, body)
  puts "Criando issue no repositório #{repo}..."
  client.create_issue(repo, title, body)
  puts "Issue criada: #{title}"
rescue => e
  puts "Erro ao criar issue: #{e.message}"
end

puts "Iniciando sincronização de issues..."

# Obtém as issues do repositório público
public_issues = fetch_issues(public_client, public_repo)
puts "Issues do repositório público obtidas com sucesso."

# Sincroniza as issues com o repositório privado
public_issues.each do |issue|
  existing_issues = fetch_issues(private_client, private_repo)
  if existing_issues.any? { |i| i[:title] == issue[:title] }
    puts "Issue '#{issue[:title]}' já existe no repositório privado. Pulando..."
  else
    create_issue(private_client, private_repo, issue[:title], issue[:body])
  end
end

puts "Sincronização concluída."
