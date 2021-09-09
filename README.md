[(Français)](#le-nom-du-projet)

## AAW ArgoCD Manifests

The manifests to deploy the AAW. To deploy this, pick a target branch (i.e. `dev` or `master`) and then deploy this application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: aaw-statcan-system
  namespace: statcan-system
spec:
  project: platform
  destination:
    namespace: statcan-system
    name: in-cluster
  source:
    repoURL: 'https://github.com/StatCan/aaw-argocd-manifests'
    path: statcan-system
    targetRevision: dev
    directory:
      recurse: true
      jsonnet: {}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

This deploys **just** the `statcan-system`. Create a few more of these to deploy the other systems. You can then load these into your favorite bootstrapping system (either another argocd instance or terraform).

### How to Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md)

### License

Unless otherwise noted, the source code of this project is covered under Crown Copyright, Government of Canada, and is distributed under the [MIT License](LICENSE).

The Canada wordmark and related graphics associated with this distribution are protected under trademark law and copyright law. No permission is granted to use them outside the parameters of the Government of Canada's corporate identity program. For more information, see [Federal identity requirements](https://www.canada.ca/en/treasury-board-secretariat/topics/government-communications/federal-identity-requirements.html).

______________________

## Le nom du projet

- Quel est ce projet?
- Comment ça marche?
- Qui utilisera ce projet?
- Quel est le but de ce projet?

### Comment contribuer

Voir [CONTRIBUTING.md](CONTRIBUTING.md)

### Licence

Sauf indication contraire, le code source de ce projet est protégé par le droit d'auteur de la Couronne du gouvernement du Canada et distribué sous la [licence MIT](LICENSE).

Le mot-symbole « Canada » et les éléments graphiques connexes liés à cette distribution sont protégés en vertu des lois portant sur les marques de commerce et le droit d'auteur. Aucune autorisation n'est accordée pour leur utilisation à l'extérieur des paramètres du programme de coordination de l'image de marque du gouvernement du Canada. Pour obtenir davantage de renseignements à ce sujet, veuillez consulter les [Exigences pour l'image de marque](https://www.canada.ca/fr/secretariat-conseil-tresor/sujets/communications-gouvernementales/exigences-image-marque.html).
