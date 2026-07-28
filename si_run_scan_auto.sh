#!/bin/bash

rm -f energies_si.dat

for a in $(seq 5.30 0.02 5.55); do
    x1=$(echo "0.25 * $a" | bc -l)
    x2=$(echo "0.75 * $a" | bc -l)
    
    half_a=$(echo "0.5 * $a" | bc -l)
    
    outfile="si_${a}.out"
    infile="si_${a}.in"
    
    cat > $infile << EOF
&CONTROL
  calculation = 'scf'
  prefix      = 'si'
  outdir      = './out/'
  pseudo_dir  = './pseudo/'
  verbosity   = 'high'
/
&SYSTEM
  ibrav       = 0
  nat         = 2
  ntyp        = 1
  ecutwfc     = 30.0
  ecutrho     = 240.0
  occupations = 'fixed'
/
&ELECTRONS
  conv_thr    = 1.0d-10
/
ATOMIC_SPECIES
  Si   28.0855   Si.us.pbesol.z_4.ld1.psl.v1.0.0-high.upf
ATOMIC_POSITIONS angstrom
  Si   $x1   $x1   $x1
  Si   $x2   $x2   $x2
CELL_PARAMETERS angstrom
  0.0000000000   $half_a       $half_a
  $half_a        0.0000000000  $half_a
  $half_a        $half_a       0.0000000000
K_POINTS automatic
  8 8 8   0 0 0
EOF
    
    echo "Berechne a = $a Å ..."
    pw.x -i $infile > $outfile
    
    # Energie extrahieren
    energy=$(grep '!' $outfile | tail -1 | awk '{print $5}')
    if [ -z "$energy" ]; then
        echo "WARNUNG: Keine Energie für a=$a gefunden"
    else
        echo "$a  $energy" >> energies_si.dat
    fi
done

echo "Fertig! Ergebnisse in energies_si.dat"
