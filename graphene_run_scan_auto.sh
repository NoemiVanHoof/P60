#!/bin/bash

# Alte Energiedatei löschen (falls vorhanden)
rm -f energies.dat

for a in $(seq 2.30 0.02 2.60); do
    # Werte berechnen (mit bc)
    a2=$(echo "-0.5 * $a" | bc -l)
    a3=$(echo "0.8660254037844386 * $a" | bc -l)
    c=$(echo "8 * $a" | bc -l)
    
    outfile="graphene_${a}.out"
    infile="graphene_${a}.in"
    
    cat > $infile << EOF
&CONTROL
  calculation = 'scf'
  prefix      = 'graphene'
  outdir      = './out/'
  pseudo_dir  = './pseudo/'
  verbosity   = 'high'
/
&SYSTEM
  ibrav       = 0
  nat         = 2
  ntyp        = 1
  ecutwfc     = 60.0
  ecutrho     = 600.0
  occupations = 'smearing'
  smearing    = 'gaussian'
  degauss     = 0.01
  nspin       = 1
/
&ELECTRONS
  conv_thr     = 1.0d-8
  mixing_beta  = 0.7
/
ATOMIC_SPECIES
  C   12.0107   C.us.pbesol.z_4.uspp.gbrv.v1.2.upf
ATOMIC_POSITIONS crystal
  C   0.000000   0.000000   0.000000
  C   0.333333   0.666667   0.000000
CELL_PARAMETERS angstrom
  $a   0.0000   0.0000
  $a2   $a3   0.0000
   0.0000   0.0000   $c
K_POINTS automatic
  18 18 1   0 0 0
EOF
    
    echo "Berechne a = $a Å ..."
    pw.x -i $infile > $outfile
    
    # Energie extrahieren (unterer Fall, da QE '!' ausgibt)
    energy=$(grep '!' $outfile | tail -1 | awk '{print $5}')
    if [ -z "$energy" ]; then
        echo "WARNUNG: Keine Energie für a=$a gefunden"
    else
        echo "$a  $energy" >> energies.dat
    fi
done

echo "Fertig! Ergebnisse in energies.dat"