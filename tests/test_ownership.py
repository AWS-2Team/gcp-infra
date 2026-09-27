"""Offline ownership guard: Terraform provisions cloud objects, never starts replication."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
LAYERS = ('05-bootstrap', '10-network', '11-vpn', '20-gke', '21-cloud-sql', '30-service-foundation', '40-edge')


class Ownership(unittest.TestCase):
    def test_all_boundaries_exist_without_operational_provisioners(self):
        for layer in LAYERS:
            files = list((ROOT / layer).glob('*.tf'))
            self.assertTrue(files, layer)
            text = '\n'.join(p.read_text() for p in files)
            self.assertNotRegex(text, r'provisioner\s+"|resource\s+"(?:null_resource|terraform_data|kubernetes_[^"]*|helm_release|google_sql_user|google_secret_manager_secret_version)"')
            self.assertNotIn('terraform_remote_state', text)

    def test_gateway_owns_load_balancer(self):
        text = '\n'.join(p.read_text() for p in (ROOT / '40-edge').glob('*.tf'))
        self.assertIn('google_certificate_manager_certificate_map', text)
        self.assertNotRegex(text, r'resource\s+"google_compute_(?:backend_service|forwarding_rule|global_forwarding_rule|url_map|target_https_proxy)"')

    def test_data_has_its_own_protected_state(self):
        text = (ROOT / '21-cloud-sql' / 'main.tf').read_text()
        self.assertRegex(text, r'deletion_protection\s*=\s*true')
        self.assertRegex(text, r'deletion_protection_enabled\s*=\s*true')
        self.assertRegex(text, r'prevent_destroy\s*=\s*true')
        prefixes = []
        for layer in LAYERS[1:]:
            content = (ROOT / layer / 'envs' / 'dev' / 'backend.hcl.example').read_text()
            self.assertNotRegex(content, r'prefix\s*=\s*"dev/(backbone|vpn|service-foundation|edge)"')
            prefixes.append(re.search(r'prefix\s*=\s*"([^"]+)"', content)[1])
        self.assertEqual(len(prefixes), len(set(prefixes)))


if __name__ == '__main__':
    unittest.main()
