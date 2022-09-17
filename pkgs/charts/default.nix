{ pkgs }:

with pkgs; with lib;

let
  charts = (import ./cert-manager.nix {})
  ;

  # Build the resulting derivation name for this chart.
  buildChartDerivationName = (chartsetName: version:
    lib.replaceStrings
      ["."] ["_"]
      "chart/${chartsetName}:${version}"
  );

  pullChart = (name: chartsetName: chart: version: {
    name = name;

    value = pkgs.fetchzip {
      url = "${chartsetName}-${version}.tgz";
      sha256 = chart.sha256;
    };
  });

  # Pull all charts in all chart sets.
  pulledCharts = lib.attrsets.foldAttrs (n: a: n // a ) {}  ( lib.attrValues(
    lib.mapAttrs (chartsetName: chartset:
    lib.attrsets.mapAttrs' (version: chart:
      pullChart (buildChartDerivationName chartsetName version) chartsetName chart version
    ) (chartset.versions)
    ) charts)
  );

  # Create preferred charts for all charts in all chart sets. These become
  # aliases to the version which is preferred.
  preferredCharts = lib.attrsets.foldAttrs (n: a: n // a ) {}  ( lib.attrValues(
    lib.mapAttrs (chartsetName: chartset:
    lib.attrsets.mapAttrs' (version: chart:
      pullChart (buildChartDerivationName chartsetName "preferred") chartsetName chart version
    ) (filterAttrs (version: _: chartset.preferredVersion == version) chartset.versions) # Filter for preferred version.
    ) charts)
  );

in pulledCharts // preferredCharts
