within OpenBLDC.Machines;
model PMSM "3ph-PMSM stator frame model"
  extends Modelica.Icons.MotorIcon;
  import Modelica.Constants.pi;
  import Modelica.Electrical.Analog;
  import Modelica.Mechanics.Rotational;
  import Modelica.SIunits;
  parameter SIunits.Inertia Jr = 0.0027 "Inertia of the rotor";
  parameter SIunits.Inertia Js = 1 "Inertia of the stator";
  parameter SIunits.Resistance R_p = 0.54 "Per phase resistance";
  parameter SIunits.Inductance L_p = 0.00145 "Per phase inductance";
  parameter Integer ppz = 1 "Pairs of poles";
  parameter SIunits.Angle ang_p(displayUnit = "rad") = 2 / 3 * pi
    "Electrical angle between 2 phases";
  parameter SIunits.MagneticFlux PhaseBEMF = 2 / 3 * 1.04
    "Back EMF constant of one single phase (peak value) [VS/rad]";
  SIunits.MagneticFlux psi_m = PhaseBEMF / ppz;
  output SIunits.Angle phiMechanical = flange.phi - support.phi;
  output SIunits.AngularVelocity wMechanical(displayUnit = "1/min") = der(phiMechanical);
  output SIunits.Angle phiElectrical = ppz * phiMechanical;
  output SIunits.AngularVelocity wElectrical = ppz * wMechanical;
  Rotational.Components.Inertia inertia_rotor(J = Jr);
  Rotational.Components.Inertia inertia_housing(J = Js);
  Rotational.Sources.Torque2 torque2;
  Modelica.SIunits.Torque tau_el;
  Analog.Interfaces.Pin a1 annotation(extent = [ -110,86; -90,106]);
  Analog.Interfaces.Pin b1 annotation(extent = [ -110,6; -90,26]);
  Analog.Interfaces.Pin c1 annotation(extent = [ -110, -74; -90, -54]);
  Analog.Basic.Resistor r_a(R = R_p);
  Analog.Basic.Resistor r_b(R = R_p);
  Analog.Basic.Resistor r_c(R = R_p);
  Analog.Basic.Inductor l_a(L = L_p);
  Analog.Basic.Inductor l_b(L = L_p);
  Analog.Basic.Inductor l_c(L = L_p);
  SIunits.MagneticFlux flux_a;
  SIunits.MagneticFlux flux_b;
  SIunits.MagneticFlux flux_c;
  SIunits.Torque tau_a;
  SIunits.Torque tau_b;
  SIunits.Torque tau_c;
  Analog.Sources.SignalVoltage u_a;
  Analog.Sources.SignalVoltage u_b;
  Analog.Sources.SignalVoltage u_c;
  Analog.Interfaces.Pin a2 annotation(extent = [ -110,54; -90,74]);
  Analog.Interfaces.Pin b2 annotation(extent = [ -110, -26; -90, -6]);
  Analog.Interfaces.Pin c2 annotation(extent = [ -110, -106; -90, -86]);

  Rotational.Interfaces.Flange_a flange
    annotation (Placement(transformation(extent={{90,-10},{110,10}})));
  Rotational.Interfaces.Support support
    annotation (Placement(transformation(extent={{90,-90},{110,-70}})));
equation
  connect(a2,r_a.p);
  connect(r_a.n,l_a.p);
  connect(l_a.n,u_a.p);
  connect(u_a.n,a1);
  connect(b2,r_b.p);
  connect(r_b.n,l_b.p);
  connect(l_b.n,u_b.p);
  connect(u_b.n,b1);
  connect(c2,r_c.p);
  connect(r_c.n,l_c.p);
  connect(l_c.n,u_c.p);
  connect(u_c.n,c1);
  flux_a = psi_m * cos(phiElectrical + 0 * ang_p);
  flux_b = psi_m * cos(phiElectrical + 1 * ang_p);
  flux_c = psi_m * cos(phiElectrical + 2 * ang_p);
  u_a.v =  -wElectrical * flux_a;
  u_b.v =  -wElectrical * flux_b;
  u_c.v =  -wElectrical * flux_c;
  tau_a = ppz * flux_a * a2.i;
  tau_b = ppz * flux_b * b2.i;
  tau_c = ppz * flux_c * c2.i;
  tau_el = -(tau_a + tau_b + tau_c);
  tau_el = torque2.tau;
  connect(flange,inertia_rotor.flange_a);
  connect(inertia_rotor.flange_b,torque2.flange_a);
  connect(torque2.flange_b,inertia_housing.flange_a);
  connect(inertia_housing.flange_b,support);
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}), graphics));
end PMSM;
