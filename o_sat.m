% from Weiss (https://doi.org/10.1016/0011-7471(70)90037-9)

function O_mgL = o_sat(T_C)
    T_K = max(T_C + 273.15, 274); 
    A1 = -173.4292;
    A2 = 249.6339;
    A3 = 143.3483;
    A4 = -21.8492;

    ln_O = A1 + A2 * (100 ./ T_K) + A3 * log(T_K / 100) + A4 * (T_K / 100).^2;
    O_molkg = exp(ln_O);  % mol/kg·atm
    O_mgL = O_molkg * 32 * 1000;  % convert to mg/L
end 