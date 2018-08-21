Improvements
============

We are modifying various pieces of the algorithm in Nalu-Wind to remove the dependence of Nalu-Wind's results on time step. For now, we are only focusing on the edge-based scheme. We use a 2D simulation of the flow past a FFA-W3-301 airfoil at an inflow velocity of 25.18 m/s and zero angle of attack as a test case. Here are the changes we have made so far in this fork of Nalu-Wind https://github.com/gantech/nalu-wind/tree/f/rau-pres.

* The ``ComputeMdot`` step is split into two parts -- ``ComputeMdot`` and ``CorrectMdot``.
* We introduced non-orthogonal corrector steps to help improve the convergence of the pressure Poisson equation for highly non-orthogonal meshes.
* We introduced relaxation factors to velocity and pressure.
* After the solution of the pressure Poisson equation, we explicitly set the pressure on the surface of the airfoil to be the same as the value at the first node normal to the wall, i.e. zero normal gradient.

Using the above modifications, we were able to achieve a time-step independent result using a full upwind scheme using the :math:`k-\omega-\textrm{SST}` turbulence model as shown in figure BLAH.


    
