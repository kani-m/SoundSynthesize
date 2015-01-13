clear;
clf()

function [out]=H(s)
  // Butterworth filter with 2 degree
  out = 1 ./ (s.^2+1.4142*s+1);
  // Butterworth filter with 5 degree
//  out = 1 ./ (s.^5+3.24*s.^4+5.24*s.^3+5.24*s.^2+3.24*s+1);
endfunction

n = 8192*2
sf = 44100;
Source = zeros(1,n);
Formant = zeros(1,n);

//V = [800 1300 2500 3500 4500]; // Vowwl for [a]
//V = [250 2100 3100 3500 4500]; // Vowel for [i]
//V = [250 1400 2200 3500 4500]; // Vowel for [u]
//V = [450 1900 2400 3500 4500]; // Voewl for [e]
V = [450  900 2600 3500 4500]; // Vowel for [o]

// Gain = 20*log10(Signal) [dB]
// As max(Signal) = 9.45,
// if Ratio = (Peaks(Signal)/Max(Signal) = [1.0 0.275 0.041 0.025 0.008]),
// then Gain ~~ [19 8 -8 -12 -22].
//
// Max of H(s) of this program may be 1.0,
// so we use Ratio*10.0*abs(H(s)) = Strong*abs(H(s))
Strong = [10.0 2.75 0.41 0.25 0.08];

bw_for = 180; //bandwidth for formant

bf = 150; // base_frequency

for i = bf:bf:n/2
  t = i/bf;
  if t <= 100 then
    Source(1,i) = 10-0.1*t;
  end
end

//Source(1) = 10000 + 100.0*rand();
//for i=1:n
//  Source(i) = Source(i) + 10.0*rand(1.0);
//end


f = 1:1:n;
omega = 2 * %pi .* f;
s = %i*omega;

for iter = 1:5
  omega_low = omega(V(iter)-bw_for);
  omega_high = omega(V(iter)+bw_for);
  omega_0 = sqrt(omega_low*omega_high);
  omega_b = omega_high - omega_low;
  Formant = Formant + Strong(iter)*abs(H((s.^2+omega_0^2) ./ (s.*omega_b)));
end

Spectrum = Source .* Formant;
for i = 1:n/2
  Spectrum(1,n-i+1) = Spectrum(1,i)
end

//plot(Source);
//plot(Formant);
//plot(20*log10(Formant));
plot(Spectrum);
//graph = gca();
//graph.data_bounds = [0 0; 5000 1.0];

snd = ifft(Spectrum);
playsnd(snd*100, sf); 

