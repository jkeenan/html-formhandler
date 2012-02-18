package HTML::FormHandler::Widget::Field::Select;
# ABSTRACT: select field rendering widget

use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

sub render {
    my $self = shift;
    my $result = shift || $self->result;
    my $id = $self->id;
    my $index = 0;
    my $multiple = $self->multiple;
    my $output = '<select name="' . $self->html_name . qq{" id="$id"};
    my $t;
    my $ele_attributes = process_attrs($self->element_attributes($result));

    $output .= ' multiple="multiple"' if $multiple;
    $output .= qq{ size="$t"} if $t = $self->size;
    $output .= $ele_attributes;
    $output .= '>';

    if( defined $self->empty_select ) {
        $t = $self->_localize($self->empty_select);
        $output .= qq{\n<option value="" id="$id.$index">$t</option>};
        $index++;
    }

    my $fif = $result->fif;
    my %fif_lookup;
    @fif_lookup{@$fif} = () if $multiple;
    foreach my $option ( @{ $self->{options} } ) {
        my $value = $option->{value};
        $output .= qq{\n<option value="}
            . $self->html_filter($value)
            . qq{" id="$id.$index"};
        if( defined $option->{disabled} && $option->{disabled} ) {
            $output .= 'disabled="disabled" ';
        }
        if ( defined $fif ) {
            if ( $multiple && exists $fif_lookup{$value} ) {
                $output .= ' selected="selected"';
            }
            elsif ( $fif eq $value ) {
                $output .= ' selected="selected"';
            }
        }
        $output .= $ele_attributes;
        my $label = $option->{label};
        $label = $self->_localize($label) if $self->localize_labels;
        $output .= '>' . ( $self->html_filter($label) || '' ) . '</option>';
        $index++;
    }
    $output .= '</select>';
    return $self->wrap_field( $result, $output );
}

1;
