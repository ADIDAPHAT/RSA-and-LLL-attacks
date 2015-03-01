def boneh_durfee(pol, modulus, mm, tt, XX, YY):
    """
    Boneh and Durfee revisited by Herrmann and May
    finds a solution if:
    * |x| < e^delta
    * |y| < e^0.5
    whenever delta < 1 - sqrt(2)/2 ~ 0.292
    """

    # change ring of pol and x
    polZ = pol.change_ring(ZZ)
    x, y = polZ.parent().gens()

    # compute polynomials
    # x-shifts
    gg = []
    for kk in range(mm + 1):
        for ii in range(mm - kk + 1):
            gg.append((x * XX)^ii * modulus^(mm - kk) * polZ(x * XX, y * YY)^kk)

    # y-shifts (selected by Herrman and May)
    for jj in range(1, tt + 1):
        for kk in range(floor(mm/tt) * jj, mm + 1):
            gg.append((y * YY)^jj * polZ(x * XX, y * YY)^kk * modulus^(mm - kk))

    gg.sort()

    # unravelled linerization (Herrman and May)
    monomials = [] # jusqu'à nn

    # x-shift
    for ii in range(mm + 1):
        for jj in range(ii + 1):
            monomials.append(x^ii * y^jj)

    # y-shift
    for jj in range(1, tt + 1):
        for kk in range(floor(mm/tt) * jj, mm + 1):
            monomials.append((x*y)^kk * y^jj)

    # construct lattice B
    nn = len(monomials)
    BB = Matrix(ZZ, nn)

    for ii in range(nn):
        for jj in range(ii):
            if jj == 0:
                BB[ii, jj] = gg[ii](0,0)
            elif monomials[jj] in gg[ii].monomials():
                BB[ii, jj] = gg[ii].monomial_coefficient(monomials[jj])

    # LLL
    BB = BB.LLL()

    print BB

    # transform shortest vectors in polynomials  
    pol1 = pol2 = 0

    for ii in range(nn):
        pol1 += monomials[ii] * BB[0, ii]
        pol2 += monomials[ii] * BB[1, ii]

    # resultant
    polx = pol1.resultant(pol2, y)
    poly = pol1.resultant(pol2, x)

    solx = polx.roots()
    soly = poly.roots()

    return solx, soly


############################################
# Test 
##########################################

# RSA gen
length = 512;
p = next_prime(2^int(round(length/2)));
q = next_prime( round(pi.n()*p) );
N = p*q;

d = 5
e = d.inverse_mod((p-1)*(q-1))

# Problem put in equation
P.<x,y> = PolynomialRing(Zmod(e))
pol = 1 + x * (5 + y)
m = 2
t = 1
X = floor(e^0.292)
Y = floor(e^0.5)

# boneh_durfee
solx, soly = boneh_durfee(pol, e, m, t, X, Y)
print solx, soly