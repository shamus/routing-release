# rubocop:disable LineLength
# rubocop:disable BlockLength
require 'rspec'
require 'yaml'
require 'bosh/template/evaluation_context'

describe 'routing-api.yml.erb' do
  let(:deployment_manifest_fragment) do
    {
      'index' => 0,
      'job' => { 'name' => 'routing-api' },
      'properties' => {
        'routing_api' => {
          'max_ttl' => '120s',
          'auth_disabled' => false,
          'metrics_reporting_interval' => '30s',
          'statsd_endpoint' => 'localhost:8125',
          'debug_address' => '127.0.0.1:17002',
          'statsd_client_flush_interval' => '300ms',
          'system_domain' => 'foo',
          'log_level' => 'info',
          'port' => 3000,
          'clients' => {
            'cfcr_routing_api_client' => {
              'secret' => 'super-secret'
            }
          },
          'router_groups' => [],
          'lock_ttl' => '10s',
          'lock_retry_interval' => '5s',
          'locket' => {
            'api_location' => '',
            'ca_cert' => '',
            'client_cert' => '',
            'client_key' => ''
          },
          'skip_consul_lock' => false,
          'admin_port' => 1597,
          'sqldb' => {
            'host' => 'foo',
            'port' => 1245,
            'type' => 'mysql',
            'schema' => 'routing_api',
            'username' => 'user',
            'password' => 'password',
            'ca_cert' => 'some-cert',
            'skip_hostname_validation' => true
          }
        },
        'release_level_backup' => false,
        'consul' => {
          'servers' => 'http://127.0.0.1:8500'
        },
        'uaa' => {
          'tls_port' => 443,
          'token_endpoint' => 'uaa.service.cf.internal',
          'ca_cert' => ''
        },
        'dns_health_check_host' => 'uaa.service.cf.internal',
        'metron' => {
          'port' => 3456
        },
        'skip_ssl_validation' => true
      }
    }
  end

  let(:erb_yaml) do
    File.read(File.join(File.dirname(__FILE__), '../jobs/routing-api/templates/routing-api.yml.erb'))
  end

  subject(:parsed_yaml) do
    binding = Bosh::Template::EvaluationContext.new(deployment_manifest_fragment).get_binding
    YAML.safe_load(ERB.new(erb_yaml).result(binding))
  end

  context 'given a generally valid manifest' do
    describe 'sqldb' do
      it 'should set skip_hostname_validation' do
        expect(parsed_yaml['sqldb']['skip_hostname_validation']).to eq(true)
      end
    end
  end
end
